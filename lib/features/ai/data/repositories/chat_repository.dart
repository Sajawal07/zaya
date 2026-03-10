import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference getChatCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats');
  }

  Stream<List<ChatMessage>> getMessages(String userId) {
    return getChatCollection(userId)
        .orderBy('timestamp', descending: false)
        .limit(5000) // User requirement
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();
    });
  }

  Future<void> saveMessage(String userId, ChatMessage message) async {
    await getChatCollection(userId).add(message.toMap());
  }

  Future<void> clearAllMessages(String userId) async {
    final snapshot = await getChatCollection(userId).get();
    final batch = _firestore.batch();
    
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

}
