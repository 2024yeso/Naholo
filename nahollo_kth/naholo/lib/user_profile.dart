// lib/models/user_profile.dart

class UserProfile {
  final String nickname;
  final int level;
  final String? introduce;
  final String? imageUrl;
  final int followerCount;
  final int followingCount;

  UserProfile({
    required this.nickname,
    required this.level,
    this.introduce,
    this.imageUrl,
    required this.followerCount,
    required this.followingCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] ?? '',
      level: json['level'] ?? 0,
      introduce: json['introduce'],
      imageUrl: json['imageUrl'],
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
    );
  }
}
