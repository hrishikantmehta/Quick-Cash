import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_atm_giver/configMaps.dart';
import 'package:mobile_atm_giver/screens/login_screen.dart';
import 'package:mobile_atm_giver/screens/main_screen.dart';
import 'package:mobile_atm_giver/screens/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // currentFirebaseUser = FirebaseAuth.instance.currentUser!;

  runApp(const MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");
DatabaseReference giversRef = FirebaseDatabase.instance.ref("givers");

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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // initialRoute: FirebaseAuth.instance.currentUser == null
      //     ? LoginScreen.id
      //     : MainScreen.id,
      initialRoute: LoginScreen.id,
      routes: {
        RegistrationScreen.id: (context) => RegistrationScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        MainScreen.id: (context) => const MainScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
