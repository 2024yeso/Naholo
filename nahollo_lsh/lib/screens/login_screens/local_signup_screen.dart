import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:nahollo/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nahollo/screens/login_screens/nickname_setting_screen.dart';
import 'package:nahollo/test_info.dart';

class LocalSignupScreen extends StatefulWidget {
  const LocalSignupScreen({super.key});

  @override
  State<LocalSignupScreen> createState() => _LocalSignupScreenState();
}

class _LocalSignupScreenState extends State<LocalSignupScreen> {
  var infoSignup = Info();
  final _formKey = GlobalKey<FormState>();
  var isIdExist = false;

  // TextEditingController로 각 입력 필드 관리
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  Future<void> checkId() async {
    // 중복 ID 확인 테스트
    try {
      var response = await http.get(
        Uri.parse("${Api.checkId}?user_id=${_userIdController.text.trim()}"),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("중복 ID 여부: ${data['available']}");
        if (data["available"] == false) {
          isIdExist = false;
        } else {
          isIdExist = true;
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signup"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("아이디(이메일)"),
                    OutlinedButton(
                      onPressed: () async {
                        await checkId();
                        if (isIdExist) {
                          Fluttertoast.showToast(msg: "이미 존재하는 아이디입니다!");
                        } else {
                          Fluttertoast.showToast(msg: "사용 가능한 아이디입니다!");
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF36226B), // 테두리 색상 (짙은 남색)
                          width: 2, // 테두리 두께
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // 둥근 모서리
                        ),
                      ),
                      child: const Text(
                        '중복확인',
                        style: TextStyle(
                          color: Color(0xFF36226B), // 텍스트 색상 (짙은 남색)
                          fontSize: 10, // 폰트 크기
                        ),
                      ),
                    ),
                  ],
                ),
                // 아이디 입력창
                TextFormField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: '이메일 주소'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '아이디(이메일)를 입력하세요.';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return '유효한 이메일 형식으로 입력하세요.';
                    }
                    if (isIdExist == true) {
                      return '이미 존재하는 아이디입니다.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 비밀번호 입력창
                TextFormField(
                  controller: _userPasswordController,
                  decoration: const InputDecoration(labelText: '비밀번호'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '비밀번호를 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 비밀번호 확인창
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: '비밀번호 확인'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '비밀번호 확인을 입력하세요.';
                    }
                    if (value != _userPasswordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(labelText: '이름'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '이름을 입력하세요.';
                    }
                    return null;
                  },
                ),

                // 회원가입 버튼
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      infoSignup.userId = _userIdController.text.trim();
                      infoSignup.userPw = _userPasswordController.text.trim();
                      infoSignup.userName = _userNameController.text.trim();
                      // 회원가입 로직
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NicknameSettingScreen(info: infoSignup)),
                      );
                    }
                  },
                  child: const Text('계속하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
