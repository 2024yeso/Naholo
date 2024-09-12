import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/models/user_model.dart';
import 'package:nahollo/providers/emailVerify_static.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/login_screens/login_emailverrify_screen.dart';
import 'package:nahollo/screens/login_screens/login_finish_screen.dart';
import 'package:nahollo/screens/login_screens/login_screen.dart';

import 'package:http/http.dart' as http;
import 'package:nahollo/test_info.dart';
import 'package:provider/provider.dart';

class NicknameSettingScreen extends StatefulWidget {
  Info info;

  NicknameSettingScreen({super.key, required this.info});

  @override
  State<NicknameSettingScreen> createState() => _NicknameSettingScreenState();
}

class _NicknameSettingScreenState extends State<NicknameSettingScreen> {
  var _isLoginSuccess = false;
  var _isInfoSend = false;
  var _isEmailSend = false;
  final TextEditingController _nicknameController = TextEditingController();
  String? _errorText;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;

  Future<void> login() async {
    //로그인 스크린에 있는 함수긴 한데 여기서만 재사용될꺼라 일단 걍 복사하긴함..ㅎ
    // Provider를 미리 가져와서 저장
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인 성공
    var res;
    final response = await http.get(
      Uri.parse(
          '${Api.baseUrl}/login/?user_id=${widget.info.userId}&user_pw=${widget.info.userPw}'),
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

      _isLoginSuccess = true;
    } else {
      Fluttertoast.showToast(
        msg: "로그인 실패",
      );
      print(
          "Login Success Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

  // 파이어베이스에 정보 저장 회원가입 함수
  Future<void> _register() async {
    try {
      // 이메일과 비밀번호로 회원가입 요청
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: widget.info.userId,
        password: widget.info.userPw,
      );

      // 이메일 인증 요청
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification(); // 이메일 인증 메일 전송
        setState(() {
          _errorMessage = "이메일에서 이메일 인증을 확인해주세요.";
        });
        _isEmailSend = true;
      }
    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException에 따른 오류 처리
      if (e.code == 'weak-password') {
        setState(() {
          _errorMessage = '비밀번호가 너무 약합니다.';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _errorMessage = '이미 사용 중인 이메일입니다.';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          _errorMessage = '이메일 형식이 잘못되었습니다.';
        });
      } else {
        setState(() {
          _errorMessage = '회원가입 실패: ${e.message}';
        });
      }
    } catch (e) {
      // 기타 예외 처리
      setState(() {
        _errorMessage = '회원가입 중 오류가 발생했습니다: $e';
      });
    }

    print(_errorMessage);
    Fluttertoast.showToast(msg: _errorMessage!);
  }

  Future<void> addUser() async {
    //my sql DB에 정보 저장  회원가입
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
      _isInfoSend = true;
    } else {
      print(
          "Add User Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

  void _submitNickname() {
    if (_nicknameController.text.isEmpty) {
      _errorText = '닉네임을 입력해주세요';
    } else if (_nicknameController.text.length >= 8) {
      _errorText = '닉네임은 최대 8자리까지 가능합니다';
    } else {
      _errorText = null;
      widget.info.nickName = _nicknameController.text;
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
                onPressed: () async {
                  _submitNickname();
                  if (EmailVerifyStatic.needEmailVerify) {
                    await _register();
                    if (context.mounted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginEmailverrifyScreen(
                              info: widget.info,
                            ),
                          ));
                    }
                  } else {
                    await addUser();
                    await login();
                    if (_isLoginSuccess) {
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginFinishScreen(),
                            ));
                      }
                    }
                  }
                },
                child: const Text('회원가입 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
