import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() async {
  // 서버 URL
  final String uploadUrl = 'http://localhost:8000/add_review/';

  // 리뷰 데이터 생성
  final Map<String, dynamic> reviewData = {
    'user_id': 'user1',
    'where_id': 1,
    'review_content': 'This is a sample review.',
    'where_like': 10,
    'where_rate': 4.5,
    'reason_menu': true,
    'reason_mood': false,
    'reason_safe': true,
    'reason_seat': false,
    'reason_transport': true,
    'reason_park': false,
    'reason_long': true,
    'reason_view': false,
    'reason_interaction': true,
    'reason_quite': false,
    'reason_photo': true,
    'reason_watch': false,
    'images': [] // 이미지 리스트는 나중에 추가
  };

  // 이미지 파일 경로 리스트
  final List<String> imagePaths = [
    'images/review1_image1.png', // 첫 번째 이미지 경로
    'images/review1_image1.png'  // 두 번째 이미지 경로
  ];

  // 이미지 파일을 Base64로 인코딩하여 리뷰 데이터에 추가
  for (String path in imagePaths) {
    try {
      // 파일을 읽어와 Base64 인코딩
      File imageFile = File(path);
      if (imageFile.existsSync()) {
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        
        // 이미지 리스트에 Base64 인코딩된 이미지 추가
        reviewData['images'].add(base64Image);
      } else {
        print('Error: File not found at path: $path');
      }
    } catch (e) {
      print('Failed to read or encode file at path: $path. Error: $e');
    }
  }

  // 서버로 데이터 전송
  try {
    final response = await http.post(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reviewData),
    );

    if (response.statusCode == 200) {
      // 성공적으로 업로드된 경우
      print('Review uploaded successfully!');
    } else {
        ('Failed to upload review. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}
