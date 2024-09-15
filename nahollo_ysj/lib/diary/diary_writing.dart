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
        backgroundColor: Colors.white,
        toolbarHeight: SizeScaler.scaleSize(context, 25, 50),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: SizeScaler.scaleSize(context, 10, 20)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            '일지 작성',
            style: TextStyle(
              fontSize: SizeScaler.scaleSize(context, 8, 16),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SizeScaler.scaleSize(context, 8, 16)),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // 작성 버튼 눌렀을 때의 동작
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
                child: Text(
                  '작성',
                  style: TextStyle(
                    fontSize: SizeScaler.scaleSize(context, 8, 16),
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(SizeScaler.scaleSize(context, 0.5, 1)),
          child: Container(
            color: const Color(0xFFBABABA), // 구분선 색상
            height: SizeScaler.scaleSize(context, 0.5, 1), // 구분선 두께
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeScaler.scaleSize(context, 16, 32)),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: SizeScaler.scaleSize(context, 10, 20)),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
