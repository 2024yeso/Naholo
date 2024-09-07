import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://127.0.0.1:8000";

Future<void> checkId() async {
  // 중복 ID 확인 테스트
  final response = await http.get(Uri.parse('$baseUrl/check_id/?user_id=user123'));

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    print("중복 ID 여부: ${data['available']}");
  } else {
    print("Check ID Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}

Future<void> testAddUser() async {
  // 회원가입 테스트
  final response = await http.post(
    Uri.parse('$baseUrl/add_user/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "USER_ID": "test_user",
      "USER_PW": "password123",
      "NAME": "Test User",
      "PHONE": "010-1234-5678",
      "BIRTH": "1990-01-01",
      "GENDER": true,
      "NICKNAME": "Tester",
      "USER_CHARACTER": "Hero",
      "LV": 1,
      "INTRODUCE": "Hello, I am a test user!",
      "IMAGE": 1
    }),
  );

  if (response.statusCode == 200) {
    print("Add User Response: ${utf8.decode(response.bodyBytes)}");
  } else {
    print("Add User Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}

Future<void> testLoginSuccess() async {
  // 로그인 성공 테스트
  var res;
  final response = await http.get(
    Uri.parse('$baseUrl/login/?user_id=test_user&user_pw=password123'),
  );

  if (response.statusCode == 200) {
    res = jsonDecode(utf8.decode(response.bodyBytes));
    print("Login Success Response: ${res["NICKNAME"]}, ${res["USER_CHARACTER"]}, ${res["LV"]}, ${res["INTRODUCE"]}");
  } else {
    print("Login Success Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}

Future<void> myPage() async {
  // 마이페이지 테스트
  var res;
  final response = await http.get(
    Uri.parse('$baseUrl/my_page/?user_id=user1'),
  );

  if (response.statusCode == 200) {
    res = jsonDecode(utf8.decode(response.bodyBytes));
    print("reviews: ${res["reviews"]}, wanted: ${res["wanted"]}");
  } else {
    print("Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}


void main() async {
/*
  print("=== Testing ID Check ===");
  await checkId();

  print("\n=== Testing User Registration ===");
  await testAddUser();
*/
  await myPage();
/*
  print("\n=== Testing Login Failure (Wrong Password) ===");
  await testLoginFailureWrongPassword();

  print("\n=== Testing Login Failure (Nonexistent User) ===");
  await testLoginFailureNonexistentUser();
*/
}
