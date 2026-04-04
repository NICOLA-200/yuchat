import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import '../services/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _usernameError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Overlay Snackbar ────────────────────────────────────────────────────────
  void _showTopSnackBar(String text, {bool isSuccess = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green.shade600 : Colors.red.shade700,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => entry.remove(),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }

  // ─── Validation ──────────────────────────────────────────────────────────────
  bool _validate() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    String? usernameErr;
    String? passwordErr;

    if (username.isEmpty) {
      usernameErr = 'Username is required';
    } else if (username.length < 3) {
      usernameErr = 'Username must be at least 3 characters';
    } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username)) {
      usernameErr = 'Username must be alphanumeric';
    }

    if (password.isEmpty) {
      passwordErr = 'Password is required';
    } else if (password.length < 8) {
      passwordErr = 'Password must be at least 8 characters';
    }

    setState(() {
      _usernameError = usernameErr;
      _passwordError = passwordErr;
    });

    return usernameErr == null && passwordErr == null;
  }

  // ─── Signup Handler ───────────────────────────────────────────────────────────
  Future<void> _handleSignup() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final message = await AuthService.signup(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        _showTopSnackBar(message, isSuccess: true);
        await Future.delayed(const Duration(seconds: 2));
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');

      if (mounted) {
        final parts = message.split('\n').where((s) => s.trim().isNotEmpty).toList();

        if (parts.length > 1) {
          for (int i = 0; i < parts.length; i++) {
            await Future.delayed(Duration(milliseconds: i == 0 ? 0 : 700));
            if (mounted) _showTopSnackBar(parts[i]);
          }
        } else {
          _showTopSnackBar(parts.first);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── Field Decoration ────────────────────────────────────────────────────────
  InputDecoration _fieldDecoration(String hint, String? errorText) {
    final hasError = errorText != null;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.transparent,
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.black, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.black, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.black, width: 1.5),
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

  // ─── Build ───────────────────────────────────────────────────────────────────
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
                const SizedBox(height: 90),
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
                      'Continue by creating an account',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        letterSpacing: 1.5,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
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
                // Sign up button
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
                    onPressed: _isLoading ? null : _handleSignup,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Sign up'),
                  ),
                ),
                const SizedBox(height: 24),
                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        'Log in',
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