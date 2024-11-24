// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_test/resources/assets_manager.dart';
import 'package:chat_test/resources/values_manager.dart';
import 'package:chat_test/services/firebase_servises/firestore_services.dart';
import 'package:chat_test/services/my_application.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final Timestamp? otherUserLastSeen;
  final bool online;
  ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserLastSeen,
    required this.online,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatEditingController = TextEditingController();

  StreamSubscription? realTimeReadChat;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    realTimeReadChat = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .snapshots()
        .listen((e) {
      FireStoreServices().markMessagesAsRead(
          chatId: widget.chatId, currentUserId: widget.currentUserId);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    FireStoreServices().updateTypingStatus(
        chatId: widget.chatId,
        currentUserId: widget.currentUserId,
        isTyping: false);
    typingTimer?.cancel();
    realTimeReadChat!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // reciever info section
            receiverInfoSection(context),

            // Messages section
            messagesSection(),

            //  Message files
            messageTypingSection()
          ],
        ),
      ),
    );
  }

  Expanded messagesSection() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(widget.chatId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final messages = snapshot.data!.docs;
                return Container(
                    color: Color(0xff121212),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe =
                                  message['senderId'] == widget.currentUserId;

                              return chatComponent(context,
                                  message: message['text'],
                                  isMe: isMe,
                                  messageTime:
                                      message['timestamp'] as Timestamp?,
                                  isRead: message['read']);
                            },
                          ),
                        ),
                        StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('chats')
                                .doc(widget.chatId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox();
                              }

                              final data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final typingUserId = data['typing'];
                              final isTyping = typingUserId != null &&
                                  typingUserId != widget.currentUserId;

                              return isTyping
                                  ? Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional.topStart,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Typing ",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            Lottie.asset(JsonAssets.typing,
                                                height: 19)
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox();
                            })
                      ],
                    ));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }

  Container receiverInfoSection(BuildContext context) {
    return Container(
      color: Color(0xff222222),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p18, vertical: AppPadding.p14),
        child: Row(
          children: [
            InkWell(
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset(ImageAssets.arrowBack)),
            SizedBox(
              width: AppSize.s20,
            ),
            Container(
              width: AppSize.s36,
              height: AppSize.s36,
              decoration: BoxDecoration(
                border:
                    Border.all(width: 2, color: Theme.of(context).primaryColor),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                  child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl:
                    'https://t3.ftcdn.net/jpg/05/16/27/58/360_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg',
                placeholder: (
                  context,
                  url,
                ) =>
                    Center(child: const CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.network(
                    'https://t3.ftcdn.net/jpg/05/16/27/58/360_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg'),
              )),
            ),
            SizedBox(
              width: AppSize.s12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffFFFFFF)),
                ),
                Text(
                  widget.online == true
                      ? 'Online'
                      : timeago.format(
                          (widget.otherUserLastSeen as Timestamp).toDate()),
                  style: TextStyle(
                      color: widget.online == true
                          ? const Color.fromARGB(255, 89, 216, 93)
                          : Color(0xffFFFFFF).withOpacity(0.5)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Container messageTypingSection() {
    return Container(
      color: Color(0xff191919),
      padding: EdgeInsets.only(
          left: AppPadding.p16, right: AppPadding.p16, top: 8, bottom: 34),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: TextFormField(
            controller: _chatEditingController,
            onChanged: (value) => _onTyping(),
            maxLines: null,
            decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Color(0xff121212)),
          )),
          SizedBox(
            width: AppSize.s12,
          ),
          InkWell(
              onTap: () {
                if (_chatEditingController.text.isEmpty) {
                  MyApplication.showToastView(
                      message: 'Cant sent an empty message');
                } else {
                  FireStoreServices().sendMessage(
                      widget.chatId,
                      widget.currentUserId,
                      _chatEditingController.text,
                      widget.otherUserId);

                  FireStoreServices().updateTypingStatus(
                      chatId: widget.chatId,
                      currentUserId: widget.currentUserId,
                      isTyping: false);

                  _chatEditingController.clear();
                }
              },
              child: Image.asset(ImageAssets.sendMessageButton))
        ],
      ),
    );
  }

  Widget chatComponent(BuildContext context,
      {required String message,
      required bool isMe,
      required Timestamp? messageTime,
      bool? isRead}) {
    final String? time = messageTime != null
        ? DateFormat('hh:mm a').format((messageTime.toDate()))
        : null;
    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.66),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: isMe ? Color(0xff048067) : Color(0xff333333),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(fontSize: 16),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time ?? "00:00 AMs",
                  style: TextStyle(fontSize: 11),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      isRead == true ? Icons.done_all : Icons.done,
                      color: isRead == true
                          ? const Color.fromARGB(255, 104, 202, 248)
                          : null,
                      size: 18,
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Timer? typingTimer;
  void _onTyping() {
    // Notify Firestore that the user is typing
    FireStoreServices().updateTypingStatus(
        chatId: widget.chatId,
        currentUserId: widget.currentUserId,
        isTyping: true);

    // Reset the timer whenever the user types
    typingTimer?.cancel();
    typingTimer = Timer(Duration(seconds: 2), () {
      // Notify Firestore that the user stopped typing after 2 seconds of inactivity
      FireStoreServices().updateTypingStatus(
          chatId: widget.chatId,
          currentUserId: widget.currentUserId,
          isTyping: false);
    });
  }
}
