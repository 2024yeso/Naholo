// services/network_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:nahollo/api/api.dart';
import '../models/review.dart';
import '../models/user_profile.dart';

class NetworkService {
  static Future<UserProfile> fetchUserProfile(String userId) async {
    final url = Uri.parse('${Api.baseUrl}/get_user_profile/?user_id=$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data);
    } else {
      throw Exception('유저 프로필 로드 실패');
    }
  }

  static Future<List<Review>> fetchReviews(String userId) async {
    final url = Uri.parse('${Api.baseUrl}/my_page/?user_id=$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reviewsJson = data['reviews'] as List;
      print(reviewsJson);
      return reviewsJson.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('리뷰 로드 실패');
    }
  }

  static Future<UserProfile> login(String userId, String password) async {
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/login/?user_id=$userId&user_pw=$password'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Base64 이미지 디코딩
      Uint8List? decodedImage;
      if (data['image'] != null && data['image'].isNotEmpty) {
        try {
          decodedImage = base64Decode(data['image']);
        } catch (e) {
          print('이미지 디코딩 실패: $e');
        }
      }

      // UserProfile 객체 생성
      return UserProfile(
        userId: data['user_id'],
        nickname: data['nickname'],
        level: data['lv'],
        introduce: data['introduce'],
        image: decodedImage,
        userCharacter: data['userCharacter'],
      );
    } else {
      throw Exception('로그인 실패: ${response.body}');
    }
  }
}
