import 'package:flutter/material.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/screens/login_finish_screen.dart';
import 'package:nahollo/temporary_server.dart';

class NicknameSettingScreen extends StatefulWidget {
  const NicknameSettingScreen({super.key});

  @override
  State<NicknameSettingScreen> createState() => _NicknameSettingScreenState();
}

class _NicknameSettingScreenState extends State<NicknameSettingScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  String? _errorText;

  void _submitNickname() {
    setState(() {
      if (_nicknameController.text.isEmpty) {
        _errorText = '닉네임을 입력해주세요';
      } else if (_nicknameController.text.length >= 8) {
        _errorText = '닉네임은 최대 8자리까지 가능합니다';
      } else {
        _errorText = null;
        user_nickname = _nicknameController.text;
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const LoginFinishScreen(), // 버튼을 누르면 TypetestScreen으로 이동
            ));
        // 닉네임을 서버로 전송하거나 다른 작업을 수행
      }
    });
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
