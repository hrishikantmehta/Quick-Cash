import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_atm_giver/configMaps.dart';
import 'package:mobile_atm_giver/main.dart';
import 'package:mobile_atm_giver/screens/login_screen.dart';
import 'package:mobile_atm_giver/screens/main_screen.dart';
import 'package:mobile_atm_giver/widgets/progress_dialog.dart';

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({Key? key}) : super(key: key);

  static const String id = "registrationScreen";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
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
                'Create Account Giver',
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
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Name",
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
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Phone",
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
                        if (nameTextEditingController.text.length < 3) {
                          displayToastMessage(
                              "Name should be at least 3 characters", context);
                        } else if (!emailTextEditingController.text
                            .contains('@')) {
                          displayToastMessage(
                              'Email address is not valid', context);
                        } else if (phoneTextEditingController.text.length <
                            10) {
                          displayToastMessage('Invalid phone number', context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          displayToastMessage(
                              'Password should be atleast 6 characters',
                              context);
                        } else {
                          registerNewUser(context);
                        }
                      },
                      child: Container(
                        height: 50.0,
                        child: const Center(
                          child: Text(
                            'Register',
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
                            context, LoginScreen.id, (route) => false);
                      },
                      child: const Text(
                        "Already have an account? Login Here.",
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

  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Registering. Please wait...",
          );
        });

    final User? firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
      email: emailTextEditingController.text,
      password: passwordTextEditingController.text,
    )
            .catchError((e) {
      Navigator.pop(context);
      displayToastMessage("Error: " + e.toString(), context);
    }))
        .user;

    if (firebaseUser != null) {
      Map userData = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };

      giversRef.child(firebaseUser.uid).set(userData);

      currentFirebaseUser = firebaseUser;
      currentUserName = userData["name"];

      displayToastMessage(
          "Congratulations, your account has been created.", context);

      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.id, (route) => false);
    } else {
      Navigator.pop(context);
      displayToastMessage("New User has not been created.", context);
    }
  }
}

void displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
