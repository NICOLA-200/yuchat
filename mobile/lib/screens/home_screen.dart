import 'package:flutter/material.dart';
import 'package:yuchat/screens/login_screen.dart';
import 'package:yuchat/screens/signup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6E6E6E), // Top dark gray
              Color(0xFF222222), // Bottom darker gray
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               // Replace from SizedBox(height: 100) down to 'easily & quickly' Text

// ── Illustration area ─────────────────────────
Expanded(
  flex: 5,
  child: Stack(
    children: [
      // Grid painter background feel via opacity boxes
      Positioned(
        top: 20, left: 0, right: 0, bottom: 0,
        child: Opacity(
          opacity: 0.06,
          child: GridPaper(
            color: Colors.white,
            divisions: 1,
            subdivisions: 1,
            interval: 40,
            child: const SizedBox.expand(),
          ),
        ),
      ),

      // Left chat bubble
      Positioned(
        top: 60, left: 0,
        child: _ChatBubble(
          text: 'Hey! Are you free tonight? 👋',
          isLeft: true,
        ),
      ),

      // Right chat bubble
      Positioned(
        top: 140, right: 0,
        child: _ChatBubble(
          text: 'Yes! Let\'s catch up 🔥',
          isLeft: false,
        ),
      ),

      // Left bubble 2
      Positioned(
        top: 230, left: 0,
        child: _ChatBubble(
          text: 'Perfect, see you at 8!',
          isLeft: true,
        ),
      ),

      // Notification badge
      Positioned(
        top: 55, left: 155,
        child: Container(
          width: 22, height: 22,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('3',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),

// ── Eyebrow label ─────────────────────────────
Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
  ),
  child: const Text(
    'YuChat',
    style: TextStyle(color: Colors.white70, fontSize: 12),
  ),
),

const SizedBox(height: 20),

// ── Headline ──────────────────────────────────
const Text(
  'Chat with\nyour friends',
  style: TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    height: 1.2,
  ),
),

const SizedBox(height: 10),

const Text(
  'easily & quickly, always.',
  style: TextStyle(
    fontSize: 16,
    color: Colors.white54,
    fontWeight: FontWeight.w400,
  ),
),

const SizedBox(height: 24),

// ── 3 micro stats ─────────────────────────────
Row(
  children: const [
    _StatChip(value: '10K+', label: 'Users'),
    SizedBox(width: 10),
    _StatChip(value: 'Fast', label: 'Real-time'),
    SizedBox(width: 10),
    _StatChip(value: 'Free', label: 'Always'),
  ],
),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
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
                    onPressed: () {
                        Navigator.push(
                            context,
                             MaterialPageRoute(builder: (context) => const SignupScreen()),
                            );
                    },
                    child: const Text('Sign up'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
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






class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isLeft;
  const _ChatBubble({required this.text, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isLeft ? 0.08 : 0.12),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isLeft ? 4 : 18),
          bottomRight: Radius.circular(isLeft ? 18 : 4),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}