import 'dart:convert';
import 'dart:typed_data';

class UserProfile {
  final String userId;
  final String nickname;
  final int level;
  final String introduce;
  final Uint8List? image;
  final String? userCharacter;
  int follower_count;
  int following_count;

  UserProfile({
    required this.userId,
    required this.nickname,
    required this.level,
    required this.introduce,
    this.image,
    this.userCharacter,
    this.follower_count = 10,
    this.following_count = 10,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    Uint8List? imageBytes;

    // 이미지가 null이 아니고 빈 문자열이 아니면 Base64 디코딩
    if (json['image'] != null && json['image'].isNotEmpty) {
      try {
        imageBytes = base64Decode(json['image']);
      } catch (e) {
        print('이미지 디코딩 실패: $e');
        imageBytes = null; // 디코딩 실패 시 null 처리
      }
    } else {
      // 이미지가 없을 경우 null 처리
      imageBytes = null;
    }

    return UserProfile(
      userId: json['USER_ID'] as String? ?? '',
      nickname: json['NICKNAME'] as String? ?? '닉네임 없음',
      level: json['LV'] as int? ?? 0,
      introduce: json['INTRODUCE'] as String? ?? '자기소개가 없습니다.',
      image: imageBytes, // 디코딩된 이미지 또는 null
      userCharacter: json['userCharacter'] as String?,
      follower_count: json['follower_count'] as int? ?? 10,
      following_count: json['following_count'] as int? ?? 10,
    );
  }
}
