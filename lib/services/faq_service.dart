import 'dart:convert';
import 'package:flutter/services.dart';

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      question: json['question'],
      answer: json['answer'],
    );
  }
}

class FAQService {
  List<FAQItem> _faqList = [];
  bool _isLoading = false;
  Future<void>? _loadFuture;

  /// Exact short phrases treated as greetings / chitchat (no RegExp).
  static const _exactGreetings = {
    'hi',
    'hii',
    'hiii',
    'hello',
    'helloo',
    'hey',
    'heyy',
    'aoa',
    'salam',
    'assalamualaikum',
    'assalam alaikum',
    'asalamualaikum',
    'asalam alaikum',
    'good morning',
    'good afternoon',
    'good evening',
    'good night',
    'how are you',
    'kaise ho',
    'kaisi ho',
    'kya haal',
    'whats up',
    'whatsup',
    'sup',
    'yo',
    'thanks',
    'thank you',
    'shukriya',
    'ok',
    'okay',
    'theek',
    'theek hai',
    'bye',
    'byee',
    'tc',
  };

  bool get isReady => _faqList.isNotEmpty;

  Future<void> loadFAQs() async {
    if (_faqList.isNotEmpty) return;
    if (_loadFuture != null) return _loadFuture!;
    _loadFuture = _doLoad();
    return _loadFuture!;
  }

  Future<void> _doLoad() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final String response =
          await rootBundle.loadString('assets/data/health_faq.json');
      final List<dynamic> data = json.decode(response);
      _faqList = data.map((json) => FAQItem.fromJson(json)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading FAQs: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// True for short chitchat that should NOT hit the FAQ DB.
  bool isGreetingOrChitchat(String query) {
    final t = query.trim();
    if (t.isEmpty) return true;
    if (t.length <= 2) return true;

    // Strip trailing punctuation: hi!!! -> hi
    final cleaned = t
        .toLowerCase()
        .replaceAll(RegExp(r'[!.?]+' '\$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return true;
    if (_exactGreetings.contains(cleaned)) return true;

    // Repeated-letter greetings: hi, hiii, hellooo, byee, etc.
    // End anchor must be non-raw '\$' because Dart interpolates $ even in raw strings.
    if (RegExp(r'^(hi+|hey+|hello+|yo+|ok+|bye+)' '\$').hasMatch(cleaned)) {
      return true;
    }
    return false;
  }

  /// Returns a match only when confidence is high.
  /// Weak / loose matches return null so Gemini can answer the real question.
  Map<String, String>? findMatch(String query) {
    if (_faqList.isEmpty) return null;
    if (isGreetingOrChitchat(query)) return null;

    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return null;

    final queryWords = _meaningfulWords(normalizedQuery);
    // Need at least one content word (e.g. "pcos", "cramps")
    if (queryWords.isEmpty) return null;

    // 1. Exact match
    for (var item in _faqList) {
      if (_normalize(item.question) == normalizedQuery) {
        return {'answer': item.answer, 'type': 'exact'};
      }
    }

    // 2. Strong containment (query is a clear substring of a FAQ question,
    //    or vice versa) — only when both sides have enough content words.
    if (normalizedQuery.length >= 12 && queryWords.length >= 2) {
      for (var item in _faqList) {
        final q = _normalize(item.question);
        final faqWords = _meaningfulWords(q);
        if (faqWords.length < 2) continue;

        if (q.contains(normalizedQuery) || normalizedQuery.contains(q)) {
          final overlap = queryWords.intersection(faqWords);
          // Require majority of query keywords to appear in the FAQ question
          if (overlap.length >= (queryWords.length * 0.7).ceil()) {
            return {'answer': item.answer, 'type': 'similar'};
          }
        }
      }
    }

    // 3. Keyword similarity — strict threshold
    FAQItem? bestMatch;
    double bestScore = 0;

    for (var item in _faqList) {
      final score =
          _calculateSimilarity(normalizedQuery, _normalize(item.question));
      if (score > bestScore) {
        bestScore = score;
        bestMatch = item;
      }
    }

    // High bar: never accept a single-keyword hit (e.g. "exercise" → PCOS FAQ).
    // Prefer Gemini for anything that isn't a clear multi-word match.
    if (bestMatch != null && bestScore >= 0.62 && queryWords.length >= 2) {
      final faqWords = _meaningfulWords(_normalize(bestMatch.question));
      final overlap = queryWords.intersection(faqWords);
      if (overlap.length >= 2) {
        return {'answer': bestMatch.answer, 'type': 'similar'};
      }
    }

    return null;
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static const _stopWords = {
    'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'to',
    'of', 'in', 'on', 'for', 'with', 'my', 'me', 'i', 'you', 'your',
    'and', 'or', 'do', 'does', 'can', 'how', 'what', 'when', 'why',
    'should', 'about', 'it', 'this', 'that', 'please', 'tell', 'know',
    'want', 'need', 'help', 'some', 'any', 'from', 'have', 'has',
  };

  Set<String> _meaningfulWords(String s) {
    return s
        .split(' ')
        .where((w) => w.length > 1 && !_stopWords.contains(w))
        .toSet();
  }

  double _calculateSimilarity(String s1, String s2) {
    final words1 = _meaningfulWords(s1);
    final words2 = _meaningfulWords(s2);
    if (words1.isEmpty || words2.isEmpty) return 0;

    final intersection = words1.intersection(words2);
    final union = words1.union(words2);
    final jaccard = intersection.length / union.length;
    final coverage = intersection.length / words1.length;
    return (jaccard * 0.4) + (coverage * 0.6);
  }
}
