import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:nahollo/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nahollo/screens/login_screens/nickname_setting_screen.dart';
import 'package:nahollo/test_info.dart';
import 'package:nahollo/util.dart';

class LocalSignupScreen extends StatefulWidget {
  const LocalSignupScreen({super.key});

  @override
  State<LocalSignupScreen> createState() => _LocalSignupScreenState();
}

class _LocalSignupScreenState extends State<LocalSignupScreen> {
  var infoSignup = Info();
  final _formKey = GlobalKey<FormState>();
  var isIdExist = false;

  bool? _isMale; // null 상태에서 남자는 true, 여자는 false로 설정

  // TextEditingController로 각 입력 필드 관리
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userBrithController = TextEditingController();

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
    final width = SizeUtil.getScreenWidth(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        //didPop == true , 뒤로가기 제스쳐가 감지되면 호출 된다.
        if (didPop) {
          print('didPop호출');
          return;
        }
        showExitDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "회원가입",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 아이디 입력창
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            labelText: '아이디(이메일)',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: "이메일 주소",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '아이디(이메일)를 입력하세요.';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return '유효한 이메일 형식으로 입력하세요.';
                            }
                            if (isIdExist == true) {
                              return '이미 존재하는 아이디입니다.';
                            }
                            return null;
                          },
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: OutlinedButton(
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
                              width: 1, // 테두리 두께
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // 둥근 모서리
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            minimumSize:
                                const Size(0, 30), // 버튼의 최소 높이를 명시적으로 설정
                          ),
                          child: const Text(
                            '중복확인',
                            style: TextStyle(
                              color: Color(0xFF36226B), // 텍스트 색상 (짙은 남색)
                              fontSize: 12, // 폰트  크기
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: width * 0.05),

                  // 비밀번호 입력창
                  TextFormField(
                    controller: _userPasswordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      hintText: "비밀번호",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '비밀번호를 입력하세요.';
                      }
                      if (value.length <= 5) {
                        return '비밀번호는 최소 6자 이상이어야합니다.';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: width * 0.05),

                  // 비밀번호 확인창
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호 확인',
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      hintText: "비밀번호 확인",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
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

                  SizedBox(height: width * 0.05),

                  TextFormField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      hintText: "실명을 입력하세요",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '이름을 입력하세요.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: width * 0.05),

                  TextFormField(
                    controller: _userBrithController,
                    decoration: const InputDecoration(
                      labelText: '생년월일',
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black), // 라벨 스타일
                      hintText: '8자리 입력',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      floatingLabelBehavior:
                          FloatingLabelBehavior.always, // 라벨이 항상 위에 표시되도록 설정
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '이름을 입력하세요.';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      // 남성 라디오 버튼
                      Row(
                        children: [
                          Transform.scale(
                            scale: 0.8, // 라디오 버튼 크기 조정 (기본 크기에서 80%로 축소)
                            child: Radio<bool>(
                              value: true,
                              groupValue: _isMale,
                              activeColor: const Color(0xFF8A2EC1),
                              onChanged: (value) {
                                setState(() {
                                  _isMale = value;
                                });
                              },
                            ),
                          ),
                          const Text(
                            '남성',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20), // 남성과 여성 버튼 사이의 간격 조정
                      // 여성 라디오 버튼
                      Row(
                        children: [
                          Transform.scale(
                            scale: 0.8, // 라디오 버튼 크기 조정 (기본 크기에서 80%로 축소)
                            child: Radio<bool>(
                              value: false,
                              groupValue: _isMale,
                              activeColor: const Color(0xFF8A2EC1),
                              onChanged: (value) {
                                setState(() {
                                  _isMale = value;
                                });
                              },
                            ),
                          ),
                          const Text(
                            '여성',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),

                  // 회원가입 버튼
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        infoSignup.userId = _userIdController.text.trim();
                        infoSignup.userPw = _userPasswordController.text.trim();
                        infoSignup.userName = _userNameController.text.trim();
                        infoSignup.birth = _userBrithController.text.trim();
                        infoSignup.gender = _isMale;
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
      ),
    );
  }
}
