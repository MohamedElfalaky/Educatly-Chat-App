import 'package:chat_test/services/cache_services.dart';
import 'package:chat_test/services/firebase_servises/push_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreServices {
  FireStoreServices._internal();

  static final FireStoreServices _instance = FireStoreServices._internal();

  factory FireStoreServices() {
    return _instance;
  }

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

//get all users
  late QuerySnapshot<Object?> allUsers;

  Future<QuerySnapshot<Object?>> getAllUsers(
      // String currentUserId
      ) async {
    allUsers = await users.get();

    return allUsers;
  }

  Stream<QuerySnapshot> getAllUsersExceptMe(
      // String currentUserId
      ) {
    User? user = FirebaseAuth.instance.currentUser;

    return users.where('uid', isNotEqualTo: user!.uid).snapshots();
  }

// get my chats (where i chated with)
  Stream<QuerySnapshot> getMyChats() {
    User? user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: user!.uid)
        .snapshots();
  }

// send a message (whether first time or not)
  Future<void> sendMessage(
      String chatId, String senderId, String text, String receiverId) async {
    DocumentReference chatRef =
        FirebaseFirestore.instance.collection('chats').doc(chatId);

    FieldValue timeStamp = FieldValue.serverTimestamp();
    // Check if chat exists
    DocumentSnapshot chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      // Create chat document with participants
      await chatRef.set({
        'participants': [
          senderId,
          receiverId
        ], // Add all relevant participant IDs
        'lastMessage': text,
        'lastMessageRead': false,
        'timestamp': timeStamp,
        "typing": null
      });
    } else {
      chatRef.update({
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

// Fetch the receiver's FCM token
    final receiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();
    final fcmToken = receiverDoc['fcmToken'];

    print('snjsnjsn ${fcmToken}');
    print('snjsnjsn ${receiverDoc.id}');
    if (fcmToken != null) {
      PushNotification.sendNotification(fcmToken, text);
    }
  }

// get messages (in chat view)
  Stream<QuerySnapshot> getMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markMessagesAsRead(
      {required String chatId, required String currentUserId}) async {
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Update all unread messages for this user to "read"
    final messagesRef = chatRef.collection('messages');
    final unreadMessages = await messagesRef
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: currentUserId)
        .get();

    for (var doc in unreadMessages.docs) {
      await doc.reference.update({'read': true});
    }

    // Update the "lastMessageRead" field in the parent chat document
    await chatRef.update({'lastMessageRead': true});
  }

// count un read messages
  Future<int> countUnReadMessages(
      {required String chatId, required String currentUserId}) async {
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Update all unread messages for this user to "read"
    final messagesRef = chatRef.collection('messages');
    final unreadMessages = await messagesRef
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: currentUserId)
        .get();

    return unreadMessages.docs.length;
  }

// update is online status
  Future<void> setUserOnlineStatus(bool isOnline) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'online': isOnline,
        'lastSeen': isOnline ? null : FieldValue.serverTimestamp(),
      });
    }
  }

// on typing feature
  Future<void> updateTypingStatus(
      {required String chatId,
      required String currentUserId,
      required bool isTyping}) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'typing': isTyping ? currentUserId : null,
    });
  }
}
