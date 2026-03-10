import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../services/faq_service.dart';
import '../features/ai/data/repositories/chat_repository.dart';
import '../features/ai/domain/models/chat_message.dart';
import 'auth_provider.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

final faqServiceProvider = Provider<FAQService>((ref) {
  return FAQService();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatMessagesProvider = StreamProvider<List<ChatMessage>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  return ref.watch(chatRepositoryProvider).getMessages(user.uid);
});

class ChatActions {
  final Ref _ref;
  ChatActions(this._ref);

  Future<void> sendMessage(ChatMessage message) async {
    final user = _ref.read(authStateProvider).value;
    if (user != null) {
      await _ref.read(chatRepositoryProvider).saveMessage(user.uid, message);
    }
  }

  Future<void> clearChats() async {
    final user = _ref.read(authStateProvider).value;
    if (user != null) {
      await _ref.read(chatRepositoryProvider).clearAllMessages(user.uid);
    }
  }
}

final chatActionsProvider = Provider<ChatActions>((ref) {
  return ChatActions(ref);
});
