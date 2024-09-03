// diary_text.dart
import 'package:flutter/material.dart';
import 'diary_comment.dart'; // 나홀로일지 댓글
import 'package:flutter_application_1/size_scaler.dart'; // 크기 조절

class DiaryText extends StatelessWidget {
  final String postTitle;
  final String postContent; // 글의 내용을 받기 위한 필드

  // 생성자에서 글 제목과 내용을 전달받습니다.
  DiaryText({required this.postTitle, required this.postContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(postTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 글 내용 표시
            Text(
              postContent,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // 댓글 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaryComment(postTitle: postTitle),
                  ),
                );
              },
              child: Text('View Comments'),
            ),
          ],
        ),
      ),
    );
  }
}