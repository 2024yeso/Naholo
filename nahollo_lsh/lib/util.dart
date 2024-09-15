// 팝업 다이얼로그 함수
import 'package:flutter/material.dart';
import 'package:nahollo/screens/login_screens/login_screen.dart';

void showExitDialog(BuildContext context) {
  //회원가입 취소 팝업창
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // 모서리 둥글게
        ),
        title: const Text(
          '회원가입을 그만하고 나갈까요?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 취소 버튼: 팝업 닫기
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200, // 버튼 배경 색
            ),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 나가기 버튼: 팝업 닫고 추가 동작 가능
              // 원하는 동작 추가 (예: 회원가입 취소, 홈으로 이동 등)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF8A2EC1), // 나가기 버튼 배경색
            ),
            child: const Text('나가기', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
