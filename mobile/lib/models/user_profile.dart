class UserProfile {
  final int id;
  final String username;
  final String slogan;
  final String profilePicture;
  final String createdAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.slogan,
    required this.profilePicture,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      slogan: json['slogan'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}