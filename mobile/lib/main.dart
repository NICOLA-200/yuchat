import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuchat/screens/home_screen.dart';
import 'package:yuchat/screens/loading_screen.dart';
import 'package:yuchat/screens/login_screen.dart';
import 'package:yuchat/screens/profile_screen.dart';
import 'package:yuchat/screens/signup_screen.dart';

void main() {
   runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YuChat',
      debugShowCheckedModeBanner: false,
        routes: {
          '/signup': (context) => const SignupScreen(),
          '/login': (context) => const LoginScreen(),
         },
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ProfileScreen()
    );
  }
}
