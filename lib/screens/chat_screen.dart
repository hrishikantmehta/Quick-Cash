import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_atm/config_maps.dart';
import '../constants.dart';
import 'package:mobile_atm/data_handler/app_data.dart';

DatabaseReference chatRef = FirebaseDatabase.instance.ref("chats");

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  static String id = 'chat_screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  late ChatScreenArguments args;
  late String messageText;
  late DatabaseReference messagesRef;

  Future<void> checkOtherEnd() async {
    args = ModalRoute.of(context)!.settings.arguments as ChatScreenArguments;
    messagesRef = FirebaseDatabase.instance
        .ref("chats")
        .child(args.mergedID)
        .child("messages");

    final snapshot = await chatRef.child(args.mergedID).get();

    if (!snapshot.exists) {
      String otherID;
      if (args.mergedID.substring(0, keyLen) != currentUserData.id) {
        otherID = args.mergedID.substring(0, keyLen);
      } else {
        otherID = args.mergedID.substring(keyLen);
      }
      chatRef
          .child(args.mergedID)
          .child("credentials")
          .set({currentUserData.id: currentUserData.name, otherID: args.name});
    }
  }

  @override
  Widget build(BuildContext context) {
    checkOtherEnd();
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Text(args.name),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<DatabaseEvent>(
              stream: messagesRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.snapshot.value != null) {
                  List<MessageBubble> messageWidgets = [];

                  final myMessages = Map<dynamic, dynamic>.from(
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>);

                  myMessages.forEach(
                    (key, value) {
                      final currentMessage = Map<String, dynamic>.from(value);
                      messageWidgets.add(
                        MessageBubble(
                          messageText: currentMessage["text"],
                          messageSender: currentMessage["sender"],
                          myMessage:
                              currentMessage["sender"] == currentUserData.id
                                  ? true
                                  : false,
                        ),
                      );
                    },
                  );

                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 20.0,
                      ),
                      children: messageWidgets,
                    ),
                  );
                }
                // print(snapshot.data!.snapshot.value);

                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Send Your Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      messagesRef.push().set({
                        'text': messageText,
                        'sender': currentUserData.id,
                      });
                    },
                    child: const Text(
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
  const MessageBubble({
    Key? key,
    required this.messageText,
    required this.messageSender,
    required this.myMessage,
  }) : super(key: key);

  final String messageText;
  final String messageSender;
  final bool myMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5.0,
            borderRadius: myMessage
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0))
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                messageText,
                style: TextStyle(
                  color: myMessage ? Colors.white : Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
            color: myMessage ? Colors.lightBlueAccent : Colors.white,
          ),
        ],
      ),
    );
  }
}
