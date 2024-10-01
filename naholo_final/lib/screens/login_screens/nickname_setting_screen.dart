import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nahollo/api/api.dart';

import 'package:nahollo/models/user_model.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/login_screens/login_finish_screen.dart';

import 'package:http/http.dart' as http;
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_info.dart';
import 'package:nahollo/util.dart';
import 'package:provider/provider.dart';

class NicknameSettingScreen extends StatefulWidget {
  Info info;

  NicknameSettingScreen({super.key, required this.info});

  @override
  State<NicknameSettingScreen> createState() => _NicknameSettingScreenState();
}

class _NicknameSettingScreenState extends State<NicknameSettingScreen> {
  bool _isNicknameGood = false;
  var _isLoginSuccess = false;
  final TextEditingController _nicknameController = TextEditingController();
  String? _errorText;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;

  Future<void> _1st_login() async {
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
        nickName: res["nickname"],
        userId: res["user_id"],
        userCharacter: res["userCharacter"],
        lv: res["lv"],
        introduce: res["introduce"],
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
        "BIRTH": widget.info.birth,
        "GENDER": widget.info.gender,
        "NICKNAME": widget.info.nickName,
        "USER_CHARACTER": "red_panda",
        "LV": 1,
        "INTRODUCE": "자기소개를 입력해주세요",
        "IMAGE": "defaultimage.png" // 문자열로 수정
      }),
    );

    if (response.statusCode == 200) {
      print("Add User Response: ${utf8.decode(response.bodyBytes)}");
    } else {
      print(
          "Add User Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

  void _submitNickname() {
    setState(() {
      if (_nicknameController.text.isEmpty) {
        _errorText = '닉네임을 입력해주세요';
      } else if (_nicknameController.text.length > 8) {
        _errorText = '닉네임은 최대 8자리까지 가능합니다';
      } else if (_nicknameController.text.length < 2) {
        _errorText = '닉네임은 최소 2자리부터 가능합니다';
      } else {
        _errorText = null;
        _isNicknameGood = true;
        widget.info.nickName = _nicknameController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.info);
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        showExitDialog(context);
      },
      child: Scaffold(
        body: Container(
          width: double.infinity, // 부모 위젯의 너비를 화면 전체로 설정
          height: double.infinity, // 부모 위젯의 높이를 화면 전체로 설정
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/nickname_bg.png'),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeScaler.scaleSize(context, 25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        '어플에서 사용하실\n닉네임을 설정해주세요!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeScaler.scaleSize(context, 12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '닉네임',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  SizedBox(
                    width: size.width * 0.8,
                    child: TextField(
                      controller: _nicknameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '한글 또는 영문 2자 이상 입력',
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 15),
                        errorText: _errorText,
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeScaler.scaleSize(context, 53)),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff8AE7ED),
                          Color(0xff6ABEFF)
                        ], // 그라데이션 색상 지정
                        begin: Alignment.topLeft, // 그라데이션 시작 위치
                        end: Alignment.bottomRight, // 그라데이션 끝 위치
                      ),
                    ),
                    width: SizeScaler.scaleSize(context, 94),
                    height: SizeScaler.scaleSize(context, 24),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent, // 그림자 제거
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(25), // 동일한 둥근 모서리 적용
                        ),
                      ),
                      onPressed: () async {
                        _submitNickname();
                        if (_isNicknameGood) {
                          await addUser();
                          await _1st_login();
                          if (_isLoginSuccess) {
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginFinishScreen(),
                                  ));
                            }
                          }
                        }
                      },
                      child: SizedBox(
                        width: SizeUtil.getScreenWidth(context) * 0.4,
                        child: Center(
                          child: Text(
                            '회원가입 완료',
                            style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 9)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
