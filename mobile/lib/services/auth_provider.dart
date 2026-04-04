import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_storage.dart';

final authTokenProvider = NotifierProvider<AuthTokenNotifier, String?>(() {
  return AuthTokenNotifier();
});

class AuthTokenNotifier extends Notifier<String?> {
  @override
  String? build() {
    _loadToken();
    return '__loading__'; // distinct from null and ""
  }

  Future<void> _loadToken() async {
    final token = await TokenStorage.readToken();
    state = token ?? ''; // no token stored → empty string, not null
  }

  Future<void> setToken(String token) async {
    await TokenStorage.saveToken(token);
    state = token;
  }

  Future<void> clearToken() async {
    await TokenStorage.deleteToken();
    state = ''; // empty string = logged out, not null = loading
  }
}