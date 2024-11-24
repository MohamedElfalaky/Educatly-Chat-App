import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_test/data/repositories/chat_repo.dart';
import 'package:chat_test/resources/values_manager.dart';
import 'package:chat_test/services/cache_services.dart';
import 'package:chat_test/services/firebase_servises/auth_service.dart';
import 'package:chat_test/services/firebase_servises/firestore_services.dart';
import 'package:chat_test/services/my_application.dart';
import 'package:chat_test/services/pre_app_config.dart';
import 'package:chat_test/utils/globals.dart';
import 'package:chat_test/views/chat/presentation/chat_screen.dart';
import 'package:chat_test/views/login/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);

    FireStoreServices().getAllUsers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        {
          await FirebaseAuth.instance.currentUser!.reload();
          setState(() {});
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
      default:
    }
  }

  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser!.emailVerified
        ? Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () async {
                      await CacheServices.instance.logOut(context);
                    },
                    icon: const Icon(Icons.logout))
              ],
              title: Text('Chat Application'),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(icon: Icon(Icons.home), text: "All users"),
                  Tab(icon: Icon(Icons.chat), text: "My chats"),
                ],
              ),
            ),
            body: FutureBuilder<QuerySnapshot>(
              future: FireStoreServices().getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TabBarView(
                    controller: _tabController,
                    children: [allUsersView(), myChats()],
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )
        : notVerified(context);
  }

  Padding allUsersView() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                const Text("Hello, Select user to chat.",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            StreamBuilder<QuerySnapshot>(
                stream: FireStoreServices().getAllUsersExceptMe(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasData) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.isEmpty
                          ? 1
                          : snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No users available"),
                          );
                        } else {
                          final otherUser = snapshot.data?.docs[index];

                          return InkWell(
                            onTap: () async {
                              final currentUserId =
                                  await CacheServices.instance.getUid();
                              final chatId = ChatRepo()
                                  .getChatId(currentUserId!, otherUser!['uid']);

                              MyApplication.navigateTo(
                                ChatScreen(
                                  chatId: chatId,
                                  currentUserId: currentUserId,
                                  otherUserId: otherUser['uid'],
                                  otherUserName: otherUser['name'],
                                  otherUserLastSeen: otherUser['lastSeen'],
                                  online: otherUser['online'],

                                  // otherUserImage: otherUser['image']
                                ),
                                Globals.navigatorKey.currentContext!,
                              );
                            },
                            child: Card(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(bottom: 8),
                                // height: 100,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    userImage(context),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      otherUser?['name'] ?? "",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Text(
                                      otherUser!['online'] == true
                                          ? 'Online'
                                          : timeago.format(
                                              (otherUser!['lastSeen']
                                                      as Timestamp)
                                                  .toDate()),
                                      style: TextStyle(
                                          color: otherUser['online'] == true
                                              ? const Color.fromARGB(
                                                  255, 89, 216, 93)
                                              : Colors.white.withOpacity(0.6)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  } else {
                    return const Text("Something went wrong");
                  }
                }),
          ],
        ),
      ),
    );
  }

  Padding myChats() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                const Text("Your chats.",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            StreamBuilder<QuerySnapshot>(
                stream: FireStoreServices().getMyChats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasData) {
                    final chats = snapshot.data!.docs;
                    log('$chats');

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.isEmpty ? 1 : chats.length,
                      itemBuilder: (context, index) {
                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No chats available"),
                          );
                        } else {
                          log('$uId');
                          final chat = chats[index];
                          // int? unReadMessages = FireStoreServices()
                          //     .countUnReadMessages(
                          //         chatId: chat.id, currentUserId: '');

                          final otherUserId = (chat['participants'] as List)
                              .firstWhere((id) => id != uId);

                          final otherUser = FireStoreServices()
                              .allUsers
                              .docs
                              .firstWhere((doc) => otherUserId == doc.id);

                          return InkWell(
                            onTap: () async {
                              final currentUserId =
                                  await CacheServices.instance.getUid();

                              //to mark last message as read
                              FireStoreServices().markMessagesAsRead(
                                  chatId: chat.id,
                                  currentUserId: currentUserId!);

                              // to recount unread messages
                              FireStoreServices().countUnReadMessages(
                                  chatId: chat.id,
                                  currentUserId: currentUserId);

                              setState(() {});

                              MyApplication.navigateTo(
                                ChatScreen(
                                    chatId: chat.id,
                                    currentUserId: currentUserId,
                                    otherUserId: otherUserId,
                                    otherUserName: otherUser['name'],
                                    otherUserLastSeen: otherUser['lastSeen'],
                                    online: otherUser['online']
                                    // otherUserImage: otherUser['image']

                                    ),
                                Globals.navigatorKey.currentContext!,
                              );
                            },
                            child: Card(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(bottom: 8),
                                // height: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    userImage(context),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          otherUser['name'],
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          chat['lastMessage'],
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          chat['timestamp'] != null
                                              ? timeago.format(
                                                  (chat['timestamp']
                                                          as Timestamp)
                                                      .toDate())
                                              : '00:00 AM',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.6)),
                                        ),
                                        FutureBuilder(
                                          future: FireStoreServices()
                                              .countUnReadMessages(
                                                  chatId: chat.id,
                                                  currentUserId: uId!),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (snapshot.data == 0) {
                                                return SizedBox();
                                              } else {
                                                return Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.green),
                                                  child: Text(
                                                      snapshot.data.toString()),
                                                );
                                              }
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  } else {
                    return const Text("Something went wrong");
                  }
                }),
          ],
        ),
      ),
    );
  }

  Container userImage(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Theme.of(context).primaryColor),
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
    );
  }

  Scaffold notVerified(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
              onTap: () async => await AuthService().signOut(),
              child: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your mail  ${FirebaseAuth.instance.currentUser!.email} is not varified \n please check your mail to verify",
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser!
                      .sendEmailVerification();

                  MyApplication.showToastView(
                      message: "mail sent successfully");
                },
                child: const Text("Send again")),
            ElevatedButton(
                onPressed: () async {
                  await AuthService().signOut();

                  MyApplication.showToastView(
                      message: "mail sent successfully");
                },
                child: const Text("Log out"))
          ],
        ),
      ),
    );
  }
}
