import 'package:flutter/material.dart';
import 'package:flutter_application_1/size_scaler.dart'; // 크기 조절

class DiaryComment extends StatelessWidget {
  final String postTitle;

  DiaryComment({required this.postTitle});

  @override
  Widget build(BuildContext context) {
    // 샘플 댓글 데이터
    final List<String> comments = [
      'Great post!',
      'Very informative.',
      'I found this really helpful.',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: SizeScaler.scaleSize(context, 25, 50),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black, size: SizeScaler.scaleSize(context, 10, 20),),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Center(
              child: Text(
                '댓글',
                style: TextStyle(
                  fontSize: SizeScaler.scaleSize(context, 8, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            actions: [SizedBox(width: SizeScaler.scaleSize(context, 20, 40))], // 화면 중앙 맞추기 위한 여백 추가
          ),
          Container(
            color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
            height: SizeScaler.scaleSize(context, 0.5, 1), // 구분선 두께
          ),
          Padding(
            padding: EdgeInsets.only(
              top: SizeScaler.scaleSize(context, 8, 16),
              left: SizeScaler.scaleSize(context, 12, 24),
              right: SizeScaler.scaleSize(context, 12, 24),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '댓글 ${comments.length}',
                style: TextStyle(
                  fontSize: SizeScaler.scaleSize(context, 6, 12),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7E7E7E),
                ),
              ),
            ),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5, 10)), // 댓글수와 첫 댓글 사이의 여백
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(comments[index]),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(SizeScaler.scaleSize(context, 16)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '댓글을 작성해주세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: SizeScaler.scaleSize(context, 8)),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // 댓글 전송 처리 로직
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
