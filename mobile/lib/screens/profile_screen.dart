import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuchat/widgets/bottom_navbar.dart';
import 'package:yuchat/providers/profile_provider.dart';
import 'package:yuchat/providers/auth_token_provider.dart';
import 'package:yuchat/screens/edit_profile_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = ref.read(authTokenProvider);
    if (token == null || token.isEmpty) return;

    // Decode JWT to get user id
    final decoded = JwtDecoder.decode(token);
    final userId = decoded['user_id'] as int? ?? 0;

    await ref.read(profileProvider.notifier).loadProfile(userId);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: profile == null
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(profile: profile),
                              ),
                            );
                            // Refresh after returning from edit
                            _loadProfile();
                          },
                    tooltip: 'Edit',
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────
            Expanded(
              child: profile == null
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 3),

                          // Avatar
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                              image: profile.profilePicture.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(profile.profilePicture),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: profile.profilePicture.isEmpty
                                ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
                                : null,
                          ),

                          const SizedBox(height: 24),

                          Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),

                          const SizedBox(height: 32),

                          Text(
                            'Slogan',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.slogan.isNotEmpty ? profile.slogan : '—',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),

                          const Spacer(flex: 4),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}