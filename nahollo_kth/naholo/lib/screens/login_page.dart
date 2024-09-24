// screens/login_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'main_scaffold.dart';
import '../services/network_service.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userIdController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userId = userIdController.text;
                final password = passwordController.text;
                await _login(context, userId, password);
              },
              child: const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login(
      BuildContext context, String userId, String password) async {
    try {
      final userProfile = await NetworkService.login(userId, password);

      // UserProvider를 사용하여 로그인된 유저 설정
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(userProfile);

      // 로그인 성공 시 MainScaffold로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScaffold(),
        ),
      );
    } catch (e) {
      print('로그인 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 실패. 다시 시도해주세요.')),
      );
    }
  }
}
