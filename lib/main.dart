import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_atm/screens/chat_list_screen.dart';
import 'package:mobile_atm/screens/chat_screen.dart';
import 'package:mobile_atm/screens/login_screen.dart';
import 'package:mobile_atm/screens/main_screen.dart';
import 'package:mobile_atm/screens/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: LoginScreen.id,
      routes: {
        RegistrationScreen.id: (context) => RegistrationScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        MainScreen.id: (context) => const MainScreen(),
        ChatScreen.id: (context) => const ChatScreen(),
        ChatListScreen.id: (context) => const ChatListScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
