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

  Future<void> loadFAQs() async {
    if (_faqList.isNotEmpty) return;
    try {
      final String response = await rootBundle.loadString('assets/data/health_faq.json');
      final List<dynamic> data = json.decode(response);
      _faqList = data.map((json) => FAQItem.fromJson(json)).toList();
    } catch (e) {
      print('Error loading FAQs: $e');
    }
  }

  Map<String, String>? findMatch(String query) {
    if (_faqList.isEmpty) return null;

    final normalizedQuery = query.toLowerCase().trim();

    // 1. Exact Match
    for (var item in _faqList) {
      if (item.question.toLowerCase().trim() == normalizedQuery) {
        return {'answer': item.answer, 'type': 'exact'};
      }
    }

    // 2. Closest Match (Simplified: Contains or high overlap)
    FAQItem? bestMatch;
    double bestScore = 0;

    for (var item in _faqList) {
      final score = _calculateSimilarity(normalizedQuery, item.question.toLowerCase());
      if (score > bestScore) {
        bestScore = score;
        bestMatch = item;
      }
    }

    if (bestMatch != null && bestScore > 0.4) { // Threshold for similarity
      return {'answer': bestMatch.answer, 'type': 'similar'};
    }

    return null;
  }

  double _calculateSimilarity(String s1, String s2) {
    final words1 = s1.split(' ').toSet();
    final words2 = s2.split(' ').toSet();
    
    final intersection = words1.intersection(words2);
    return intersection.length / (words1.length > words2.length ? words1.length : words2.length);
  }
}
