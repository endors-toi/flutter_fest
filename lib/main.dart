import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fest/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_fest/services/authentication_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: FlexThemeData.light(scheme: FlexScheme.purpleM3),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.purpleM3),
        themeMode: ThemeMode.system,
        home: LoginPage(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
