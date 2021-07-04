import 'package:flash_chat_new/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_new/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id =
      'chat_screen'; //static so I can access it without building entire widget and const so it cant be changed anywhere ele

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageText = 'Hello';
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  var loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    //messageStream();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var message in messages.docs) {
  //     print(message.data());
  //   }
  // }

  // void messageStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot) {
  //       print(message.data());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // messageStream();
                // await FirebaseAuth.instance.signOut();
                // Navigator.pushNamed(context, LoginScreen.id);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('messages').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data?.docs;
                  List<MessageBubble> messageBubbles = [];
                  if (messages != null)
                    for (var message in messages) {
                      final messageText = message['text'];
                      final messageSender = message['sender'];
                      final messageBubble = MessageBubble(
                        sender: messageSender,
                        message: messageText,
                      );
                      messageBubbles.add(messageBubble);
                    }
                  return Expanded(
                    child: ListView(
                      children: messageBubbles,
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                return Container();
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value; //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String? sender;
  final String? message;

  MessageBubble({this.sender, this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10.0, 0, 10, 0),
          child: Text('$sender', style: TextStyle(color: Colors.black38)),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  //offset: Offset(0, 3),
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Text(
            '$message',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
