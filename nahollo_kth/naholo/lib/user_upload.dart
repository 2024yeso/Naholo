import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() async {
  // 서버 URL
  final String uploadUrl = 'http://localhost:8000/upload_profile_image/';

  // 사용자 ID
  final String userId = 'user1';

  // 현재 작업 디렉토리 출력
  print('Current directory: ${Directory.current.path}');

  // 이미지 파일 경로 설정
  final String imagePath = 'images/image1.jpg'; // 상대 경로

  // 이미지 파일 객체 생성
  File imageFile = File(imagePath);

  // 이미지 파일 경로와 파일 존재 여부 출력
  print('Image file path: $imageFile');
  print('File exists: ${imageFile.existsSync()}');

  // 이미지 파일이 존재하는지 확인
  if (!imageFile.existsSync()) {
    print('Error: File not found!');
    return;
  }

  // 서버로 이미지 파일 업로드
  try {
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['user_id'] = userId; // 요청 필드에 사용자 ID 추가
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path)); // 이미지 파일 추가

    // 서버로 요청 전송 및 응답 받기
    var response = await request.send();

    // 응답 처리
    if (response.statusCode == 200) {
      // 응답 바디 확인
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = json.decode(responseBody);
      print('Upload successful! Image URL: ${decodedResponse['image_base64']}');
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}
