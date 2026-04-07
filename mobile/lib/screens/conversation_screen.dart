import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:yuchat/models/user_model.dart';
import 'package:yuchat/providers/auth_token_provider.dart';
import 'package:yuchat/screens/chat_screen.dart';
import 'package:yuchat/services/auth_service.dart';
import 'package:yuchat/widgets/bottom_navbar.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      final data = await AuthService.getConversations();
      if (!mounted) return;
      setState(() {
        _conversations = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
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
            // ── Header ──────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chats',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),

            // ── Body ────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(_error!,
                                  style: TextStyle(
                                      color: Colors.grey.shade400)),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _error = null;
                                  });
                                  _fetchConversations();
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _conversations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline,
                                      size: 56,
                                      color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No conversations yet',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Go to Home and message someone!',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchConversations,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                itemCount: _conversations.length,
                                separatorBuilder: (_, __) => Divider(
                                  color: Colors.grey.shade100,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final c = _conversations[index];
                                  return _ConversationTile(
                                    conversation: c,
                                    onTap: () {
                                      final token =
                                          ref.read(authTokenProvider);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatScreen(
                                            roomId: c['room_id'],
                                            otherUser: UserModel(
                                              id: c['other_user_id'],
                                              name: c['other_user_name'],
                                              avatarUrl: c['other_user_picture']
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? c['other_user_picture']
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ).then((_) => _fetchConversations());
                                    },
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}

// ── Conversation tile ──────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final dynamic conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String name = conversation['other_user_name'] ?? '';
    final String lastMsg = conversation['last_message'] ?? '';
    final bool isMe = conversation['is_me'] ?? false;
    final String? picture = conversation['other_user_picture'];
    final DateTime? sentAt = conversation['last_message_at'] != null
        ? DateTime.tryParse(conversation['last_message_at'])
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  picture != null && picture.isNotEmpty
                      ? NetworkImage(picture)
                      : null,
              child: picture == null || picture.isEmpty
                  ? Icon(Icons.person,
                      size: 28, color: Colors.grey.shade400)
                  : null,
            ),

            const SizedBox(width: 14),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isMe ? 'You: $lastMsg' : lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      // ✅ Bold if received (not sent by me)
                      fontWeight: isMe
                          ? FontWeight.w400
                          : FontWeight.w700,
                      color: isMe
                          ? Colors.grey.shade500
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),

            // Time
            if (sentAt != null)
              Text(
                timeago.format(sentAt, allowFromNow: true),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}