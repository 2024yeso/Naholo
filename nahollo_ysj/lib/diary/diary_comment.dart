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
            title: Center(
              child: Text(
                '댓글',
                style: TextStyle(
                  fontSize: SizeScaler.scaleSize(context, 8.0),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
            height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
          ),
          Padding(
            padding: EdgeInsets.only(
              top: SizeScaler.scaleSize(context, 8.0),
              left: SizeScaler.scaleSize(context, 12.0),
              right: SizeScaler.scaleSize(context, 12.0),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '댓글 ${comments.length}',
                style: TextStyle(
                  fontSize: SizeScaler.scaleSize(context, 6),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7E7E7E),
                ),
              ),
            ),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 10, 10)), // 댓글수와 첫 댓글 사이의 여백
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
                      hintText: 'Add a comment...',
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
