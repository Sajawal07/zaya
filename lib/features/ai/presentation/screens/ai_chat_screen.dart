import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/app_colors.dart';
import '../../../../providers/ai_provider.dart';
import '../../domain/models/chat_message.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final ChatMessage _initialGreeting = ChatMessage(
    content: "Hi! I'm Zaya, your personal wellness assistant. How are you feeling today? You can ask me about your cycle, PCOS diet tips, or any symptoms you're experiencing.",
    type: MessageType.ai,
    timestamp: DateTime.now(),
  );

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

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider);

    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.nudeRose.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.nudeRose),
            ),
            const SizedBox(width: 12),
            Text(
              'Zaya AI',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 20,
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
          child: Container(color: AppColors.mistySage.withOpacity(0.2), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                final displayMessages = messages.isEmpty 
                    ? [_initialGreeting] 
                    : messages;
                
                // Auto-scroll to bottom when data changes
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: displayMessages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == displayMessages.length) {
                      return _buildTypingIndicator();
                    }
                    final message = displayMessages[index];
                    return _buildMessage(message);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.nudeRose)),
              error: (err, stack) => Center(child: Text('Error loading chat: $err')),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  void _confirmClearChats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all chats?'),
        content: const Text('This will permanently delete your entire conversation history with Zaya.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.nudeRose : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: AppColors.nudeRose.withOpacity(0.05),
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
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.nudeRose,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Zaya is thinking...',
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

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.mistySage.withOpacity(0.1),
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
                  hintText: 'Ask about your health...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: AppColors.oldLace.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: AppColors.mistySage.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: AppColors.nudeRose),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: AppColors.mistySage.withOpacity(0.1)),
                  ),
                ),
                onSubmitted: (_) => _isTyping ? null : _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              onPressed: _isTyping ? null : _sendMessage,
              backgroundColor: _isTyping 
                  ? AppColors.mistySage 
                  : AppColors.nudeRose,
              elevation: _isTyping ? 0 : 2,
              mini: true,
              child: const Icon(Icons.send_rounded, color: AppColors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

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

    // Save user message to Firestore
    await ref.read(chatActionsProvider).sendMessage(userMessage);

    String response;
    const disclaimer = "\n\n**Disclaimer:** *This is general informational guidance. The answer may not be fully accurate for your specific condition. Please consult a qualified doctor for final advice.*";

    final faqService = ref.read(faqServiceProvider);
    final match = faqService.findMatch(text);

    if (match != null) {
      if (match['type'] == 'exact') {
        response = match['answer']! + disclaimer;
      } else {
        response = "**Notice:** *An exact answer was not found. Showing a similar response that may relate to your question.*\n\n" + match['answer']! + disclaimer;
      }
    } else {
      // Fallback with AI or standard fallback message
      final aiService = ref.read(aiServiceProvider);
      final currentMessages = ref.read(chatMessagesProvider).value ?? [];
      final history = currentMessages.map((m) {
        return m.type == MessageType.user 
            ? Content.text(m.content) 
            : Content.model([TextPart(m.content)]);
      }).toList();

      final aiResponse = await aiService.getResponse(text, history: history);
      
      if (aiResponse.toLowerCase().contains("i'm sorry") || aiResponse.toLowerCase().contains("couldn't process")) {
        response = "Sorry, we could not find a relevant answer at this time. Please consult a doctor for proper guidance." + disclaimer;
      } else {
        response = aiResponse + disclaimer;
      }
    }

    if (!mounted) return;

    final aiMessage = ChatMessage(
      content: response,
      type: MessageType.ai,
      timestamp: DateTime.now(),
    );

    // Save response to Firestore
    await ref.read(chatActionsProvider).sendMessage(aiMessage);

    setState(() {
      _isTyping = false;
    });

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
}
