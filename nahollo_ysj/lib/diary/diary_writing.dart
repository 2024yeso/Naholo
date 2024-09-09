// diary_writing.dart
import 'package:flutter/material.dart';
import 'diary_text.dart'; // 나홀로일지 글 상세보기
import 'package:flutter_application_1/size_scaler.dart'; // 크기 조절

class DiaryWriting extends StatefulWidget {
  @override
  _DiaryWritingState createState() => _DiaryWritingState();
}

class _DiaryWritingState extends State<DiaryWriting> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 글 제목과 내용을 받아서 diary_text.dart로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaryText(
                      postTitle: _titleController.text,
                      postContent: _contentController.text,
                      author: '작성자', // 작성자를 고정값으로 설정
                      createdAt: DateTime.now(), // 현재 시간을 작성 시간으로 설정
                    ),
                  ),
                );
              },
              child: Text('Submit and View Post'),
            ),
          ],
        ),
      ),
    );
  }
}

// 글 작성 후 서버로 전송하는 코드 추가