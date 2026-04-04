import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yuchat/models/user_profile.dart';
import 'package:yuchat/providers/profile_provider.dart';
import 'package:yuchat/providers/auth_token_provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:io';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _sloganController;
  String? _pickedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _sloganController = TextEditingController(text: widget.profile.slogan);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _sloganController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImagePath = picked.path);
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final token = ref.read(authTokenProvider);
      final decoded = JwtDecoder.decode(token!);
      final userId = decoded['user_id'] as int? ?? 0;

      await ref.read(profileProvider.notifier).updateProfile(
        userId: userId,
        username: _usernameController.text.trim(),
        slogan: _sloganController.text.trim(),
        profilePicturePath: _pickedImagePath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Color(0xFF2D2D2D), fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Avatar picker ──────────────────────────
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      image: _pickedImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_pickedImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : widget.profile.profilePicture.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.profile.profilePicture),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (_pickedImagePath == null && widget.profile.profilePicture.isEmpty)
                        ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              'Tap to change photo',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 32),

            // ── Username field ─────────────────────────
            _buildField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Enter your username',
              maxLength: 30,
            ),

            const SizedBox(height: 20),

            // ── Slogan field ───────────────────────────
            _buildField(
              controller: _sloganController,
              label: 'Slogan',
              hint: 'Something about you...',
              maxLength: 150,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            counterStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple),
            ),
          ),
        ),
      ],
    );
  }
}