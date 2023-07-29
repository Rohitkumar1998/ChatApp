import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  var _newMessageController = TextEditingController();
  void dispose() {
    _newMessageController.dispose();
    super.dispose();
  }

  void submitMessage() async {
    final enterMessage = _newMessageController.text;
    if (enterMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _newMessageController.clear(); //for clear the meassage
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': enterMessage,
      'createAt': Timestamp.now(),
      'uesrId': user.uid,
      "userName": userData.data()!['username'],
      'userImage': userData.data()!['image_url']
    });
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(children: [
        Expanded(
            child: TextField(
          controller: _newMessageController,
          textCapitalization: TextCapitalization.sentences,
          enableSuggestions: true,
          autocorrect: true,
          decoration: InputDecoration(label: Text("Send a message")),
        )),
        IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: submitMessage,
            icon: Icon(Icons.send))
      ]),
    );
  }
}
