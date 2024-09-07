import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/screens/login_screens/login_finish_screen.dart';
import 'package:nahollo/screens/login_screens/login_screen.dart';
import 'package:nahollo/temporary_server.dart';
import 'package:http/http.dart' as http;
import 'package:nahollo/test_info.dart';

class NicknameSettingScreen extends StatefulWidget {
  Info info;

  NicknameSettingScreen({super.key, required this.info});

  @override
  State<NicknameSettingScreen> createState() => _NicknameSettingScreenState();
}

class _NicknameSettingScreenState extends State<NicknameSettingScreen> {
  var isInfoSend = false;
  final TextEditingController _nicknameController = TextEditingController();
  String? _errorText;

  Future<void> testAddUser() async {
    // 회원가입 테스트
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/add_user/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "USER_ID": widget.info.userId,
        "USER_PW": widget.info.userPw,
        "NAME": widget.info.userName,
        "PHONE": "010-1234-5678",
        "BIRTH": "1990-01-01",
        "GENDER": true,
        "NICKNAME": widget.info.nickName,
        "USER_CHARACTER": "Hero",
        "LV": 1,
        "INTRODUCE": "Hello, I am a test user!",
        "IMAGE": 1
      }),
    );

    if (response.statusCode == 200) {
      print("Add User Response: ${utf8.decode(response.bodyBytes)}");
      isInfoSend = true;
    } else {
      print(
          "Add User Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

  void _submitNickname() async {
    if (_nicknameController.text.isEmpty) {
      _errorText = '닉네임을 입력해주세요';
    } else if (_nicknameController.text.length >= 8) {
      _errorText = '닉네임은 최대 8자리까지 가능합니다';
    } else {
      _errorText = null;
      widget.info.nickName = _nicknameController.text;
      await testAddUser();
      setState(() {
        if (isInfoSend) {
          Fluttertoast.showToast(msg: "화원가입에 성공했습니다!");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          Fluttertoast.showToast(msg: "잠시후 다시 시도해주세요.");
        }
        // 닉네임을 서버로 전송하거나 다른 작업을 수행
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: darkpurpleColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '어플에서 사용하실 닉네임을 설정해주세요!',
                style: TextStyle(
                  color: lightpurpleColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              SizedBox(
                width: size.width * 0.8,
                child: TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '닉네임을 입력해주세요',
                    errorText: _errorText,
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.08),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightpurpleColor,
                  foregroundColor: darkpurpleColor,
                ),
                onPressed: _submitNickname,
                child: const Text('회원가입 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
