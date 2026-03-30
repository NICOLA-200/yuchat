import 'package:flutter/material.dart';
import 'package:yuchat/widgets/bottom_navbar.dart';


class UserModel {
  final String name;
  final String? avatarUrl;

  const UserModel({required this.name, this.avatarUrl});
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Sample users list — replace with real data source
  final List<UserModel> _allUsers = const [
    UserModel(name: 'Mugisha Frank'),
    UserModel(name: 'Mugisha Frank'),
    UserModel(name: 'Mugisha Frank'),
    UserModel(name: 'Mugisha Frank'),
    UserModel(name: 'Mugisha Frank'),
    UserModel(name: 'Mugisha Frank'),
    UserModel(name: 'Mugisha Frank'),
  ];

  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = _allUsers;
    _searchController.addListener(_onSearchChanged);
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
            // Search bar
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
                  hintText: '',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                ),
              ),
            ),

            // Users list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: _filteredUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return _UserTile(user: user);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
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
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
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