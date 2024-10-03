// models/user_profile.dart

import 'dart:convert';
import 'dart:typed_data';

class UserProfile {
  final String userId;
  final String nickname;
  final int level;
  final String introduce;
  final Uint8List? image;
  final String? userCharacter;
  int? follower_count = 0;
  int? following_count = 0;

  UserProfile({
    required this.userId,
    required this.nickname,
    required this.level,
    required this.introduce,
    this.image,
    this.userCharacter,
    this.follower_count,
    this.following_count,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    Uint8List? imageBytes;
    if (json['image'] != null && json['image'].isNotEmpty) {
      try {
        imageBytes = base64Decode(json['image']);
      } catch (e) {
        print('이미지 디코딩 실패: $e');
        imageBytes = null;
      }
    }

    return UserProfile(
      userId: json['USER_ID'] as String? ?? '',
      nickname: json['NICKNAME'] as String? ?? '닉네임 없음',
      level: json['LV'] as int? ?? 0,
      introduce: json['INTRODUCE'] as String? ?? '자기소개가 없습니다.',
      image: imageBytes,
      userCharacter: json['userCharacter'] as String?,
      follower_count: json['follower_count'] as int? ?? 10,
      following_count: json['following_count'] as int? ?? 10,
    );
  }
}
