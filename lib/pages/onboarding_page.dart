import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fest/pages/eventos_page.dart';
import 'package:flutter_fest/providers/authentication_provider.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  User? _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnBoardingSlider(
        finishButtonText: 'Empezar',
        onFinish: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => EventosPage())),
        totalPage: 3,
        speed: 1.8,
        pageBodies: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/onboarding.png',
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                Text(
                  'Bienvenido a FlutterFest',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Descubre eventos increíbles e interactúa con la comunidad.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/concert.jpg',
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                Text(
                  'Explora Eventos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Explora una variedad de eventos, desde conciertos hasta sesiones académicas.\n\n¡O quizás una pijamada!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 20),
                Image.asset(
                  'assets/images/sleepover.jpg',
                  fit: BoxFit.cover,
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Crea y Comparte',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Entra con tu cuenta, crea tus propios eventos y comparte tus experiencias en el chat.',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                _user != null
                    ? Column(
                        children: [
                          Text('¡Bienvenido!',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Image.network(_user!.photoURL!),
                          SizedBox(height: 10),
                          Text('${_user!.displayName}'),
                        ],
                      )
                    : Container(
                        width: double.infinity,
                        height: 60,
                        child: SignInButton(
                          Buttons.google,
                          elevation: 10,
                          text: 'Iniciar sesión',
                          onPressed: () async {
                            await Provider.of<AuthenticationProvider>(context,
                                    listen: false)
                                .signOut();
                            await Provider.of<AuthenticationProvider>(context,
                                    listen: false)
                                .signInWithGoogle();
                            setState(() {
                              _user = Provider.of<AuthenticationProvider>(
                                      context,
                                      listen: false)
                                  .user;
                            });
                          },
                        ),
                      ),
                SizedBox(height: 150)
              ],
            ),
          ),
        ],
        background: [
          Container(
            color: Colors.blue,
          ),
          Container(
            color: Colors.green,
          ),
          Container(
            color: Colors.purple,
          ),
        ],
        headerBackgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
      ),
    );
  }
}
