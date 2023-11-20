import 'package:flutter/material.dart';
import 'package:flutter_fest/pages/eventos_page.dart';
import 'package:flutter_fest/services/firebase_auth_service.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 50,
          child: SignInButton(
            Buttons.google,
            onPressed: () async {
              var user = await FirebaseAuthService().signInWithGoogle();
              if (user != null) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => EventosPage()),
                    (route) => false);
              }
            },
          ),
        ),
      ),
    );
  }
}
