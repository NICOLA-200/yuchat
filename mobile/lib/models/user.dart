class UserModel {
  final int id;
  final String name;
  final String? avatarUrl;

  const UserModel({required this.id, required this.name, this.avatarUrl});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['username'] ?? '',
      avatarUrl: json['profile_picture'],
    );
  }
}