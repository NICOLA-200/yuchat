import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_storage.dart';
import '../models/user.dart';
import 'dart:io';

class AuthService {

  
  // Add this helper inside AuthService:
  static String _handleError(dynamic e) {
    if (e is SocketException)
      return 'Server unreachable. Check your connection.';
    if (e is http.ClientException) return 'Network issue. Please try again.';
    return e.toString().replaceAll('Exception: ', '');
  }

  // Change this to your backend server URL
  static const String baseUrl =
      'https://yuchatbackend.fatepepe66.workers.dev/api'; // Android emulator
  // For iOS simulator or physical device, use: 'http://localhost:8080' or your machine IP

  /// Sign up with username and password
  static Future<String> signup(String username, String password) async {
    try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
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
  } catch(e) {
    throw Exception(_handleError(e));
  }
  }

  /// Login with username and password
  static Future<String> login(String username, String password) async {
    try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['access_token'] ?? data['data']?['token'] ?? '';
    } else {
      // Handle structured backend errors the same way as signup
      if (data['details'] != null) {
        throw Exception((data['details'] as List).join('\n'));
      }
      throw Exception(data['error'] ?? data['message'] ?? 'Login failed');
    }
  } catch(e) {
    throw Exception(_handleError(e));
  }
  }

  static Future<void> deleteAccount() async {
    try {
    final token = await TokenStorage.readToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/auth/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to delete account');
    }
  } catch(e) {
    throw Exception(_handleError(e));
  }
  }

  // ── Get profile by ID ──────────────────────────────────
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
    final token = await TokenStorage.readToken();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['error'] ?? 'Failed to fetch profile');
  } catch(e) {
    throw Exception(_handleError(e));
  }
  }

  // ── Update profile ─────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? username,
    String? slogan,
    String? profilePicturePath, // local file path if picking image
  }) async {
    try {
    final token = await TokenStorage.readToken();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/profile/$userId'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    if (username != null && username.isNotEmpty) {
      request.fields['username'] = username;
    }
    if (slogan != null && slogan.isNotEmpty) {
      request.fields['slogan'] = slogan;
    }
    if (profilePicturePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicturePath,
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) return data;
    if (response.statusCode == 409) throw Exception('Username already taken');
    throw Exception(data['error'] ?? 'Failed to update profile');
  } catch(e) {
    throw Exception(_handleError(e));
  }
  }

  static Future<List<UserModel>> getAllUsers() async {

    
    try {
      final token = await TokenStorage.readToken();
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch users');
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }



  // services/auth_service.dart
static String getRoomId(int myId, int otherUserId) {
  final ids = [myId, otherUserId]..sort();
  return '${ids[0]}_${ids[1]}';
}


static Future<List<dynamic>> getConversations() async {
  final token = await TokenStorage.readToken();
  final response = await http.get(
    Uri.parse('$baseUrl/conversations'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  }
  throw Exception(_handleError('Failed to fetch conversations'));
}
}
