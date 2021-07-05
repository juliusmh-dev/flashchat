import 'package:flash_chat_new/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_new/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id =
      'chat_screen'; //static so I can access it without building entire widget and const so it cant be changed anywhere ele

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  String messageText = 'Hello';
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value; //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'timestamp': Timestamp.now(),
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

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').orderBy('timestamp', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data?.docs;
          List<MessageBubble> messageBubbles = [];
          if (messages != null)
            for (var message in messages) {
              final messageText = message['text'];
              final messageSender = message['sender'];

              final currentUser = loggedInUser?.email;

              if (currentUser == messageSender) {
                //Message is from the logged in user.
              }

              final messageBubble = MessageBubble(
                sender: messageSender,
                message: messageText,
                isMe: currentUser == messageSender,
              );
              messageBubbles.add(messageBubble);
            }
          return Expanded(
            child: ListView(
              reverse: true,
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
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String? sender;
  final String? message;
  final bool? isMe;
  CrossAxisAlignment alignmentMe = CrossAxisAlignment.end;
  Color bubbleColor = Colors.lightBlueAccent;

  MessageBubble({this.sender, this.message, this.isMe});

  @override
  Widget build(BuildContext context) {
    if (isMe == true) {
      alignmentMe = CrossAxisAlignment.end;
      bubbleColor = Colors.lightBlueAccent;
    } else {
      alignmentMe = CrossAxisAlignment.start;
      bubbleColor = Colors.white;
    }
    return Column(
      crossAxisAlignment: isMe!
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start, //alignmentMe
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10.0, 0, 10, 2.0),
          child: Text('$sender',
              style: TextStyle(color: Colors.black38, fontSize: 12.0)),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color:
                bubbleColor, //oder inline if statement mit: isMe ? Colors.lightBlueAccent : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                //offset: Offset(0, 3),
              )
            ],
            borderRadius: isMe!
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
          ),
          child: Text(
            '$message',
            style: TextStyle(color: isMe! ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}
