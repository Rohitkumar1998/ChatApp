import 'package:app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});
  Widget build(BuildContext context) {
    final authentictedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No message found'),
            );
          }
          if (chatSnapshot.hasError) {
            return Center(
              child: Text("ther is somthing wrong"),
            );
          }
          final loadedMessage = chatSnapshot.data!.docs;
          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              itemCount: loadedMessage.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedMessage[index].data();
                final nextChatMessage = index + 1 < loadedMessage.length
                    ? loadedMessage[index + 1]
                    : null;
                final currentMessageUserId = chatMessage['uesrId'];
                final nextmessageUserId =
                    nextChatMessage != null ? nextChatMessage['uesrId'] : null;
                final nextUserIsSame =
                    nextmessageUserId == currentMessageUserId;
                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authentictedUser.uid == currentMessageUserId);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['userImage'],
                      username: chatMessage['username'],
                      message: chatMessage['text'],
                      isMe: authentictedUser.uid == currentMessageUserId);
                }
              });
        });
  }
}
