import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepo {
  // Generate a unique chat ID (e.g., combining two user IDs)
  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }
}
