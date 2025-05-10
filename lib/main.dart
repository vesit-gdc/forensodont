import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forensodont/pages/about.dart';
import 'package:forensodont/pages/credentials/authgate.dart';
import 'package:forensodont/pages/credentials/details.dart';
import 'package:forensodont/pages/credentials/login.dart';
import 'package:forensodont/pages/credentials/register.dart';
import 'package:forensodont/pages/home.dart';
import 'package:forensodont/pages/landingpage.dart';
import 'package:forensodont/pages/profile.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFA7D3DE),
      ),
      routes: {
        AuthGate.id: (context) => const AuthGate(),
        LandingPage.id: (context) => const LandingPage(),
        HomePage.id: (context) => const HomePage(),
        LoginPage.id: (context) => const LoginPage(),
        RegisterPage.id: (context) => const RegisterPage(),
        RegistrationDetailsPage.id : (context) => const RegistrationDetailsPage(),
        ProfilePage.id : (context) => const ProfilePage(),
        About.id : (context) => const About()
      },
      initialRoute: AuthGate.id,
    );
  }
}
