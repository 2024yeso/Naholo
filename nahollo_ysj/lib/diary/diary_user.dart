// diary_user.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/size_scaler.dart'; // 크기 조절

class DiaryUser extends StatelessWidget {
  final String author;

  DiaryUser({required this.author});

  @override
  Widget build(BuildContext context) {
    // 샘플 데이터
    final List<String> userPosts = [
      '오늘의 일기',
      '지난 주의 여행',
      '가장 좋아하는 레시피',
      '새로운 취미 찾기',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('$author\'s Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 사진 및 이름
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(width: 16.0),
                Text(
                  author,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // 작성한 포스트 목록
            Expanded(
              child: ListView.builder(
                itemCount: userPosts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(userPosts[index]),
                    onTap: () {
                      // 클릭 시 포스트 상세 페이지로 이동 (여기서는 단순히 알림을 띄우도록 함)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Clicked on ${userPosts[index]}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
