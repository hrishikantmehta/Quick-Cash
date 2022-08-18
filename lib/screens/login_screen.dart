import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_atm_giver/configMaps.dart';
import 'package:mobile_atm_giver/data_handler/app_data.dart';
import 'package:mobile_atm_giver/main.dart';
import 'package:mobile_atm_giver/screens/main_screen.dart';
import 'package:mobile_atm_giver/screens/registration_screen.dart';
import 'package:mobile_atm_giver/widgets/progress_dialog.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  static const String id = "loginScreen";

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 65.0,
              ),
              const Image(
                image: AssetImage('images/logo.png'),
                width: 200.0,
                height: 200.0,
                alignment: Alignment.center,
              ),
              const SizedBox(
                height: 15.0,
              ),
              const Text(
                'Login Giver',
                style: TextStyle(
                  fontSize: 24.0,
                  fontFamily: "Brand Bold",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    RaisedButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      onPressed: () {
                        if (!emailTextEditingController.text.contains('@')) {
                          displayToastMessage(
                              'Email address is not valid', context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          displayToastMessage(
                              'Password should be atleast 6 characters',
                              context);
                        } else {
                          loginAndAuthenticateUser(context);
                        }
                      },
                      child: Container(
                        height: 50.0,
                        child: const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, RegistrationScreen.id, (route) => false);
                      },
                      child: const Text(
                        "Don't have an account? Register Here.",
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Authenticating. Please wait...",
          );
        });

    final User? firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((e) {
      Navigator.pop(context);
      displayToastMessage("Error: " + e, context);
    }))
        .user;

    if (firebaseUser != null) {
      DataSnapshot snapshot = await giversRef.child(firebaseUser.uid).get();
      if (snapshot.exists) {
        currentFirebaseUser = firebaseUser;
        currentUserName = snapshot.child('name').value.toString();
        Navigator.pushNamedAndRemoveUntil(
            context, MainScreen.id, (route) => false);
        displayToastMessage("You are logged In now", context);
      } else {
        Navigator.pop(context);
        _firebaseAuth.signOut();
        displayToastMessage(
            "No record exists for this user. Please create new account.",
            context);
      }
    } else {
      Navigator.pop(context);
      displayToastMessage("Error Occurred. Can't log In", context);
    }
  }
}
