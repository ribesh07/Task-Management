import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  Future<void> saveMessage(String chatId, String token, String text) {
    return FirebaseFirestore.instance.collection('chats/$chatId/messages').add({
      'token': token,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
