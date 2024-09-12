import 'package:fluttertoast/fluttertoast.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/models/user_model.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 로그인 함수
  Future<bool> login(String userId, String userPw, context) async {
    // Provider를 미리 가져와서 저장
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    var res;
    final response = await http.get(
      Uri.parse(
          '${Api.baseUrl}/login/?user_id=${userId.trim()}&user_pw=${userPw.trim()}'),
    );

    if (response.statusCode == 200) {
      res = jsonDecode(utf8.decode(response.bodyBytes));

      // UserModel을 생성하여 provider에 저장
      UserModel user = UserModel(
        nickName: res["NICKNAME"],
        userCharacter: res["USER_CHARACTER"],
        lv: res["LV"],
        introduce: res["INTRODUCE"],
      );

      // provider에 유저 정보 저장
      userProvider.setUser(user);

      Fluttertoast.showToast(
        msg: res["message"],
      );
      print(
          "Login Success Response: ${res["NICKNAME"]}, ${res["USER_CHARACTER"]}, ${res["LV"]}, ${res["INTRODUCE"]}");

      return true;
    } else {
      Fluttertoast.showToast(
        msg: "로그인 실패",
      );
      print(
          "Login Success Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
      return false;
    }
  }

  // 회원가입 함수 (MySQL에 사용자 정보 저장)
  Future<bool> addUser(Map<String, dynamic> userInfo) async {
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/add_user/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userInfo), // 사용자의 정보 JSON으로 변환
    );

    if (response.statusCode == 200) {
      print("Add User Response: ${utf8.decode(response.bodyBytes)}");
      Fluttertoast.showToast(msg: "회원가입 성공");
      return true;
    } else {
      print(
          "Add User Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
      Fluttertoast.showToast(msg: "회원가입 실패");
      return false;
    }
  }
}
