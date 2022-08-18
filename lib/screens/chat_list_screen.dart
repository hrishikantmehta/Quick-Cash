import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:mobile_atm/config_maps.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  static String id = 'chat_list_screen';

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Chat"),
      ),
      body: Container(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: FirebaseDatabase.instance
              .ref("chats")
              .orderByChild("credential")
              .equalTo("abc")
              .orderByChild("path"),
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            print(snapshot.key);
            print(currentUserData.id);
            return Container(
              height: 100,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.person),
                  SizedBox(
                    width: 6,
                  ),
                  Text("Hello"),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
