import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/login_platform.dart';
import 'package:nahollo/models/user_model.dart';
import 'package:nahollo/providers/emailVerify_static.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/login_screens/local_signup_screen.dart';
import 'package:nahollo/screens/login_screens/nickname_setting_screen.dart';
import 'package:nahollo/screens/main_screen.dart';

import 'package:http/http.dart' as http;
import 'package:nahollo/api/api.dart';
import 'package:nahollo/test_info.dart';
import 'package:nahollo/util.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var infoLogin = Info();
  LoginPlatform _loginPlatform = LoginPlatform.none;

  var isLoginSuccess = false;

  // TextEditingController를 생성해서 입력한 값을 제어
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');
      var naholloGoogle = "${googleUser.email}.google";
      try {
        var response = await http.get(
          Uri.parse("${Api.checkId}?user_id=${googleUser.email}.google"),
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          print("중복 ID 여부: ${data['available']}");
          if (data["available"] == false) {
            //signup
            //false가 원래 아이디가 없는거
            setState(() {
              infoLogin.userName = googleUser.displayName; //그냥 계정이름
              infoLogin.userId =
                  naholloGoogle; // 나홀로 버전 구글 이메일 --> 원래 이메일에 .google이 붙음
              infoLogin.userPw = googleUser.id; // 고유 아이디
              EmailVerifyStatic.needEmailVerify = false;
              _loginPlatform = LoginPlatform.google;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NicknameSettingScreen(info: infoLogin),
                ),
              );
            });
          } else {
            login(naholloGoogle, googleUser.id); // 로그인
          }
        }
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  void signOut() async {
    switch (_loginPlatform) {
      case LoginPlatform.google:
        // 추가
        await GoogleSignIn().signOut();
        break;
      case LoginPlatform.none:
        break;
    }

    setState(() {
      _loginPlatform = LoginPlatform.none;
    });
  }

  void disconnect() async {
    await GoogleSignIn().disconnect();
    print('로그아웃됨!');

    setState(() {
      _loginPlatform = LoginPlatform.none;
    });
  }

  Future<void> login(String id, String pw) async {
    // Provider를 미리 가져와서 저장
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인 성공
    var res;
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/login/?user_id=$id&user_pw=$pw'),
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
      isLoginSuccess = true;
      if (context.mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MainScreen()));
      }
    } else {
      Fluttertoast.showToast(
        msg: "로그인 실패",
      );
      print(
          "Login Success Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        //didPop == true , 뒤로가기 제스쳐가 감지되면 호출 된다.
        if (didPop) {
          print('didPop호출');
          return;
        }
        showAppExitDialog(context);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/light_purple_bg.png'),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/nahollo_logo_human_white.svg',
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                  ),
                  SvgPicture.asset(
                    'assets/images/nahollo_logo_name_white.svg',
                    width: size.width * 0.3,
                    height: size.width * 0.1,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  const Text(
                    'SNS로 빠른 회원가입',
                    style: TextStyle(
                      fontSize: 10,
                      color: darkpurpleColor,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          signInWithGoogle();
                          if (isLoginSuccess) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MainScreen()));
                          }
                        },
                        child: Container(
                          child: SvgPicture.asset(
                            'assets/images/google_icon.svg',
                            width: size.width * 0.15,
                            height: size.width * 0.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  const Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  /* GestureDetector(
                        onTap: () {
                          disconnect();
                        },
                        child: Container(
                          child: const Text(
                            "로그아웃",
                            style: TextStyle(
                              color: lightpurpleColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ), */
                  // 아이디 입력창
                  Container(
                    width: size.width * 0.8,
                    height: size.width * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      textAlign: TextAlign.start,
                      controller: _idController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                        hintText: '아이디 입력',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 10),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: size.width * 0.05),

                  // 비밀번호 입력창
                  Container(
                    width: size.width * 0.8,
                    height: size.width * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      textAlign: TextAlign.start,
                      controller: _pwController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                        hintText: '비밀번호 입력',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 아이디 찾기, 비밀번호 찾기, 회원가입
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("    "),
                      const Text(
                        '아이디 찾기',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      const Text(
                        "|",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      const Text(
                        '비밀번호 찾기',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      const Text(
                        "|",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LocalSignupScreen()),
                          );
                        },
                        child: const Text(
                          '회원가입',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      const Text("    "),
                    ],
                  ),
                  SizedBox(height: size.width * 0.15),

                  // 로그인 버튼
                  ElevatedButton(
                    onPressed: () {
                      login(
                        _idController.text.trim(),
                        _pwController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // 버튼 색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 70),
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(color: darkpurpleColor),
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
