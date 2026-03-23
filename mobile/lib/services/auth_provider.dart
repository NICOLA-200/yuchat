import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_storage.dart';

final authTokenProvider = StateNotifierProvider<AuthTokenNotifier, String?>(
  (_) => AuthTokenNotifier(),
);

class AuthTokenNotifier extends StateNotifier<String?> {
  AuthTokenNotifier() : super(null) {
    _loadToken();
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