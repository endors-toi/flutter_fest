import 'package:flutter/material.dart';
import 'package:flutter_fest/pages/eventos_page.dart';
import 'package:flutter_fest/services/authentication_provider.dart';
import 'package:provider/provider.dart';
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
              await Provider.of<AuthenticationProvider>(context, listen: false)
                  .signInWithGoogle();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventosPage()),
              );
            },
          ),
        ),
      ),
    );
  }
}
