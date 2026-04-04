import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

// Holds the currently loaded profile
final profileProvider = NotifierProvider<ProfileNotifier, UserProfile?>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() => null;

  Future<void> loadProfile(int userId) async {
    final data = await AuthService.getProfile(userId);
    state = UserProfile.fromJson(data);
  }

  Future<void> updateProfile({
    required int userId,
    String? username,
    String? slogan,
    String? profilePicturePath,
  }) async {
    final data = await AuthService.updateProfile(
      userId: userId,
      username: username,
      slogan: slogan,
      profilePicturePath: profilePicturePath,
    );
    state = UserProfile.fromJson(data);
  }
}