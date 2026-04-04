import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuchat/screens/home_screen.dart';
import 'package:yuchat/screens/loading_screen.dart';
import 'package:yuchat/screens/login_screen.dart';
import 'package:yuchat/screens/profile_screen.dart';
import 'package:yuchat/screens/signup_screen.dart';
import 'package:yuchat/screens/users_screen.dart';
import 'package:yuchat/screens/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YuChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/home':    (context) => const UsersScreen(),
        '/chat':    (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/signup':  (context) => const SignupScreen(),
        '/login':   (context) => const LoginScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/settings': (conext) => const SettingsScreen(),     },
      home: const SettingsScreen(),
    );
  }
}