import 'package:flutter/material.dart';
import 'package:nahollo/screens/login_screens/login_screen.dart';
import 'package:video_player/video_player.dart';

class StartLogoScreen extends StatefulWidget {
  const StartLogoScreen({super.key});

  @override
  State<StartLogoScreen> createState() => _StartLogoScreenState();
}

class _StartLogoScreenState extends State<StartLogoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/images/cat.mp4') // 앱에 있는 동영상 경로
          ..initialize().then((_) {
            setState(() {}); // 초기화 후 상태 업데이트
            _controller.play(); // 자동 재생
            _controller.setLooping(false);
          });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        // 재생이 끝났을 때
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ));
      }
    });
  }

  /* @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 2초 후에 다음 화면으로 이동
    Future.delayed(const Duration(seconds: 2), () {
      // 홈 화면으로 이동 (여기서 HomeScreen은 다음에 보여줄 화면을 의미)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }
*/

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
        /* Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/nahollo_logo_purple.svg', // 로컬에 저장된 SVG 파일 경로
              width: screenWidth * 0.5,
              height: screenWidth * 0.5,
            ),
            SvgPicture.asset(
              'assets/images/nahollo_name_purple.svg', // 로컬에 저장된 SVG 파일 경로
              width: screenWidth * 0.5,
              height: screenWidth * 0.15,
            )
          ],
        ), */
      ),
    );
  }
}
