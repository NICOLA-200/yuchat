import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuchat/screens/home_screen.dart';
import 'package:yuchat/screens/loading_screen.dart';
import 'package:yuchat/screens/login_screen.dart';
import 'package:yuchat/screens/profile_screen.dart';
import 'package:yuchat/screens/signup_screen.dart';
import 'package:yuchat/screens/users_screen.dart';
import 'package:yuchat/screens/settings_screen.dart';
import 'package:yuchat/services/auth_provider.dart';

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
        '/home':     (context) => const UsersScreen(),
        '/chat':     (context) => const UsersScreen(),
        '/profile':  (context) => const ProfileScreen(),
        '/signup':   (context) => const SignupScreen(),
        '/login':    (context) => const LoginScreen(),
        '/loading':  (context) => const LoadingScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      home: const _AppRouter(),
    );
  }
}

/// Watches the token and decides which screen to show
class _AppRouter extends ConsumerWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);

    // Still loading token from SharedPreferences — show splash
    if (token == null) {
      return const LoadingScreen();
    }

    // Token exists → go to app
    if (token.isNotEmpty) {
      return const UsersScreen();
    }

    // No token → go to signup
    return const HomeScreen();
  }
}