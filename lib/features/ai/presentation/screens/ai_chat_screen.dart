import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_mode.dart';
import '../../../../core/premium_limits.dart';
import 'package:hercycle_bloom/features/pregnancy/domain/pregnancy_service.dart';
import '../../../../providers/ai_provider.dart';
import '../../../../providers/metrics_provider.dart';
import '../../../../services/ai_service.dart';
import '../../domain/models/chat_message.dart';
import 'package:hercycle_bloom/providers/premium_provider.dart';
import 'package:hercycle_bloom/features/profile/presentation/screens/premium_paywall_screen.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  ChatMessage _buildGreeting(AppMode mode) {
    final text = mode == AppMode.pregnancy
        ? "Hi! I'm HerCycle Bloom 🌱 Ask me anything about your pregnancy week, symptoms, nutrition, or just say hello — I'm here for you."
        : "Hi! I'm HerCycle Bloom 💗 Ask me about your cycle, symptoms, nutrition, or just say hello — I'll answer what you ask.";
    return ChatMessage(content: text, type: MessageType.ai, timestamp: DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    await ref.read(faqServiceProvider).loadFAQs();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _countUserMessagesToday(List<ChatMessage> messages) {
    final now = DateTime.now();
    return messages
        .where((m) =>
            m.type == MessageType.user &&
            m.timestamp.year == now.year &&
            m.timestamp.month == now.month &&
            m.timestamp.day == now.day)
        .length;
  }

  String _localGreetingReply(String text) {
    final lower = text.toLowerCase().trim();
    if (lower.contains('thank')) {
      return "You're welcome! Ask me anything whenever you need.";
    }
    if (lower.contains('bye') || lower.contains('good night')) {
      return 'Take care! Talk to you soon.';
    }
    if (lower.contains('how are you')) {
      return "I'm doing great, thank you! How can I help you today?";
    }
    return "Hello! 👋 How can I help you today?";
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider);
    final mode = ref.watch(appModeProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final dailyLimit = PremiumLimits.aiDailyLimit(isPremium);

    int userMessagesToday = 0;
    if (messagesAsync.hasValue) {
      userMessagesToday = _countUserMessagesToday(messagesAsync.value!);
    }
    final bool isLimitReached = userMessagesToday >= dailyLimit;
    final remaining = (dailyLimit - userMessagesToday).clamp(0, dailyLimit);

    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.nudeRose.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.nudeRose),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HerCycle Bloom AI',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  Text(
                    isLimitReached
                        ? 'Daily limit reached'
                        : '$remaining of $dailyLimit questions left today',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.nudeRose),
            tooltip: 'Clear All Chats',
            onPressed: () => _confirmClearChats(context),
          ),
        ],
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.mistySage.withValues(alpha: 0.2), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                final displayMessages =
                    messages.isEmpty ? [_buildGreeting(mode)] : messages;
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: displayMessages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == displayMessages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessage(displayMessages[index]);
                  },
                );
              },
              loading: () => const AppLoaderCentered(),
              error: (err, stack) =>
                  Center(child: Text('Error loading chat: $err')),
            ),
          ),
          if (isLimitReached) _buildLimitReachedUI(isPremium: isPremium),
          _buildInputArea(isLimitReached),
        ],
      ),
    );
  }

  void _confirmClearChats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all chats?'),
        content: const Text(
            'This will permanently delete your entire conversation history with HerCycle Bloom.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatActionsProvider).clearChats();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.type == MessageType.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.nudeRose : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft:
                isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight:
                isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: AppColors.nudeRose.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: isUser
            ? Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                    ),
              )
            : MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.bodyMedium,
                  strong: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoader(size: 20),
            const SizedBox(width: 8),
            Text(
              'HerCycle Bloom is thinking...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isLimitReached) {
    if (isLimitReached) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.mistySage.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_isTyping,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.oldLace.withValues(alpha: 0.5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                        color: AppColors.mistySage.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: AppColors.nudeRose),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                        color: AppColors.mistySage.withValues(alpha: 0.1)),
                  ),
                ),
                onSubmitted: (_) => _isTyping ? null : _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              onPressed: _isTyping ? null : _sendMessage,
              backgroundColor:
                  _isTyping ? AppColors.mistySage : AppColors.nudeRose,
              elevation: _isTyping ? 0 : 2,
              mini: true,
              child: const Icon(Icons.send_rounded,
                  color: AppColors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final isPremium = ref.read(isPremiumProvider);
    final dailyLimit = PremiumLimits.aiDailyLimit(isPremium);
    final existing = ref.read(chatMessagesProvider).value ?? [];
    if (_countUserMessagesToday(existing) >= dailyLimit) {
      setState(() {});
      return;
    }

    final userMessage = ChatMessage(
      content: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    await ref.read(chatActionsProvider).sendMessage(userMessage);

    const disclaimer =
        '\n\n**Disclaimer:** *This is general informational guidance — not a substitute for medical advice. Please consult a qualified doctor for personal care.*';

    final faqService = ref.read(faqServiceProvider);
    await faqService.loadFAQs();

    String response;

    // 1) Greetings / chitchat → local short reply (never FAQ / Gemini / PCOS)
    if (faqService.isGreetingOrChitchat(text)) {
      response = _localGreetingReply(text);
    } else {
      // 2) Strong local FAQ match only
      final match = faqService.findMatch(text);
      if (match != null) {
        response = match['type'] == 'exact'
            ? match['answer']! + disclaimer
            : '**Related answer from our knowledge base:**\n\n${match['answer']!}$disclaimer';
      } else {
        // 3) Otherwise Gemini answers the exact question
        final aiService = ref.read(aiServiceProvider);
        final currentMessages = ref.read(chatMessagesProvider).value ?? [];
        final historySource =
            currentMessages.where((m) => m.content.trim().isNotEmpty).toList();
        if (historySource.isNotEmpty &&
            historySource.last.type == MessageType.user &&
            historySource.last.content.trim() == text) {
          historySource.removeLast();
        }

        final history = <Content>[];
        final recent = historySource.length > 12
            ? historySource.sublist(historySource.length - 12)
            : historySource;
        for (final m in recent) {
          // Skip greetings and PCOS-heavy FAQ dumps that poison context
          if (m.type == MessageType.user &&
              faqService.isGreetingOrChitchat(m.content)) {
            continue;
          }
          final lowerAi = m.content.toLowerCase();
          final userAskedPcos = text.toLowerCase().contains('pcos');
          if (m.type == MessageType.ai &&
              (lowerAi.contains('knowledge base') ||
                  (lowerAi.contains('pcos') && !userAskedPcos))) {
            continue;
          }
          history.add(
            m.type == MessageType.user
                ? Content.text(m.content)
                : Content.model([TextPart(m.content)]),
          );
        }

        // Keep last 8 turns max after filtering
        final trimmedHistory =
            history.length > 8 ? history.sublist(history.length - 8) : history;

        final mode = ref.read(appModeProvider);
        final metrics = ref.read(userMetricsProvider).value;
        int? pregnancyWeek;
        if (mode == AppMode.pregnancy && metrics?.lastPeriodDate != null) {
          final startDate = metrics!.lastPeriodDate!.toLocal();
          final progress = PregnancyService.calculateProgress(lastPeriodDate: startDate);
          pregnancyWeek = progress['week'];
        }

        final aiResponse = await aiService.getResponse(
          text,
          history: trimmedHistory,
          mode: mode == AppMode.pregnancy
              ? AiContextMode.pregnancy
              : AiContextMode.cycle,
          pregnancyWeek: pregnancyWeek,
        );

        if (aiResponse == 'AI_NOT_CONFIGURED') {
          response =
              "Live AI isn't configured in this build. Local answers still work for known FAQ topics — for full Gemini replies, run the app with a Gemini API key (`--dart-define-from-file=dart_defines.json`).";
        } else {
          final lower = aiResponse.toLowerCase();
          final looksLikeHealthAdvice = lower.contains('symptom') ||
              lower.contains('doctor') ||
              lower.contains('treatment') ||
              lower.contains('cycle') ||
              lower.contains('period') ||
              lower.contains('pregnan') ||
              lower.contains('hormone') ||
              lower.contains('pcos') ||
              lower.contains('nutrition') ||
              lower.contains('supplement') ||
              aiResponse.length > 220;
          final alreadyHasDisclaimer = lower.contains('disclaimer') ||
              lower.contains('medical advice') ||
              lower.contains('consult a doctor') ||
              lower.contains('consult a qualified');
          response = (looksLikeHealthAdvice && !alreadyHasDisclaimer)
              ? aiResponse + disclaimer
              : aiResponse;
        }
      }
    }

    if (!mounted) return;

    await ref.read(chatActionsProvider).sendMessage(
          ChatMessage(
            content: response,
            type: MessageType.ai,
            timestamp: DateTime.now(),
          ),
        );

    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildLimitReachedUI({required bool isPremium}) {
    final limit = PremiumLimits.aiDailyLimit(isPremium);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.mistySage.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_clock_rounded,
              color: AppColors.pregnancyGold, size: 40),
          const SizedBox(height: 16),
          Text(
            'Daily Limit Reached',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isPremium
                ? "You've used all $limit Premium AI questions for today. Come back tomorrow for more."
                : 'Free users get ${PremiumLimits.freeAiMessagesPerDay} AI questions per day (including hi / hello). Upgrade to Premium for ${PremiumLimits.premiumAiMessagesPerDay} questions/day plus advanced insights.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          if (!isPremium) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PremiumPaywallScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.nudeRose,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Upgrade to Premium'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
