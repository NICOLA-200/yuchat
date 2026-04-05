import 'package:flutter/material.dart';
import 'package:yuchat/screens/login_screen.dart';
import 'package:yuchat/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:yuchat/widgets/bottom_navbar.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'view_user_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchUsers();
  }

  // In _fetchUsers() — data comes raw from API as List<Map<String,dynamic>>
  Future<void> _fetchUsers() async {
    try {
      final List<UserModel> users =
          await AuthService.getAllUsers(); // ✅ already parsed
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((u) => u.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar — unchanged
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                  hintText: 'Search users...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            // Body
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.grey.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _error = null;
                              });
                              _fetchUsers();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      itemCount: _filteredUsers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewUserScreen(userId: user.id),
                              ),
                            );
                          },
                          child: _UserTile(user: user),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  const _UserTile({required this.user});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Icon(Icons.person, color: Colors.grey.shade500, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          // Name
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          // Message button
          ElevatedButton(
            onPressed: () {
              // Navigate to chat with this user
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D3D3D),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Message'),
          ),
        ],
      ),
    );
  }
}
