import 'package:flutter/material.dart';
import 'package:yuchat/services/auth_service.dart';
import 'package:yuchat/models/user_profile.dart';

class ViewUserScreen extends StatefulWidget {
  final int userId;
  const ViewUserScreen({super.key, required this.userId});

  @override
  State<ViewUserScreen> createState() => _ViewUserScreenState();
}

class _ViewUserScreenState extends State<ViewUserScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await AuthService.getProfile(widget.userId);
      setState(() {
        _profile = UserProfile.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(width: 40), // balance the back button
                ],
              ),
            ),

            // ── Body ────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.grey.shade400, size: 48),
                              const SizedBox(height: 12),
                              Text(_error!,
                                  style:
                                      TextStyle(color: Colors.grey.shade500)),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _error = null;
                                  });
                                  _fetchProfile();
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : Column(
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
                                image: _profile!.profilePicture.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            _profile!.profilePicture),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _profile!.profilePicture.isEmpty
                                  ? Icon(Icons.person,
                                      size: 50, color: Colors.grey.shade400)
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
                              _profile!.username,
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
                              _profile!.slogan.isNotEmpty
                                  ? _profile!.slogan
                                  : '—',
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
          ],
        ),
      ),
    );
  }
}