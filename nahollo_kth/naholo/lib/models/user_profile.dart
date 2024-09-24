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

  UserProfile({
    required this.userId,
    required this.nickname,
    required this.level,
    required this.introduce,
    this.image,
    this.userCharacter,
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
      userId: json['user_id'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '닉네임 없음',
      level: json['level'] as int? ?? 0,
      introduce: json['introduce'] as String? ?? '자기소개가 없습니다.',
      image: imageBytes,
      userCharacter: json['userCharacter'] as String?,
    );
  }
}
