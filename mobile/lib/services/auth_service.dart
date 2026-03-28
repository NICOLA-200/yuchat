import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  // Change this to your backend server URL
  static const String baseUrl = 'http://192.168.1.69:8080/api'; // Android emulator
  // For iOS simulator or physical device, use: 'http://localhost:8080' or your machine IP

  /// Sign up with username and password
static Future<String> signup(String username, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'password': password,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 201) {
    return data['message'] ?? 'Account created successfully';
  } else {
    // Handle structured backend errors
    if (data['details'] != null) {
      return (data['details'] as List).join('\n');
    }
    throw Exception(data['error'] ?? 'Signup failed');
  }
}

  /// Login with username and password
  static Future<String> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] ?? data['data']['token'] ?? '';
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
}
