import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _usernameError;
  String? _passwordError;
  String? _generalError;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    String? usernameErr;
    String? passwordErr;

    if (username.isEmpty) {
      usernameErr = 'Username is required';
    } else if (username.length < 3) {
      usernameErr = 'Username must be at least 3 characters';
    }

    if (password.isEmpty) {
      passwordErr = 'Password is required';
    } else if (password.length < 8) {
      passwordErr = 'Password must be at least 8 characters';
    }

    setState(() {
      _usernameError = usernameErr;
      _passwordError = passwordErr;
      _generalError = null;
    });

    return usernameErr == null && passwordErr == null;
  }

  Future<void> _handleLogin() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await AuthService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      await ref.read(authTokenProvider.notifier).setToken(token);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _generalError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _fieldDecoration(String hint, String? errorText) {
    final hasError = errorText != null;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.transparent,
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.black,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.black,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.black,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                // Logo
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset('lib/assets/images/logo.png'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Login to continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        letterSpacing: 1.5,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 90),
                // General error (e.g. wrong credentials from backend)
                if (_generalError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _generalError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Username field
                TextField(
                  controller: _usernameController,
                  onChanged: (_) {
                    if (_usernameError != null) {
                      setState(() => _usernameError = null);
                    }
                  },
                  decoration: _fieldDecoration('Your username', _usernameError),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                  decoration: _fieldDecoration('Your password', _passwordError),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 36),
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 24),
                // Don't have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}