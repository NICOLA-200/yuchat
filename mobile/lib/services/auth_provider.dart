import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_storage.dart';

// 1. Use NotifierProvider instead
final authTokenProvider = NotifierProvider<AuthTokenNotifier, String?>(() {
  return AuthTokenNotifier();
});

// 2. Extend Notifier instead of StateNotifier
class AuthTokenNotifier extends Notifier<String?> {
  
  // 3. Logic previously in the constructor goes in 'build'
  @override
  String? build() {
    _loadToken();
    return null; // Initial state
  }

  Future<void> _loadToken() async {
    state = await TokenStorage.readToken();
  }

  Future<void> setToken(String token) async {
    await TokenStorage.saveToken(token);
    state = token;
  }

  Future<void> clearToken() async {
    await TokenStorage.deleteToken();
    state = null;
  }
}
