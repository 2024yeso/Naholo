// diary_comment.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/size_scaler.dart'; // 크기 조절

class DiaryComment extends StatelessWidget {
  final String postTitle;

  DiaryComment({required this.postTitle});

  @override
  Widget build(BuildContext context) {
    // 샘플 댓글 및 답글 데이터
    final List<Map<String, dynamic>> comments = [
      {
        'author': 'JohnDoe',
        'content': 'Great post!',
        'isReply': false,
      },
      {
        'author': 'JaneSmith',
        'content': 'Very informative.',
        'isReply': true,
      },
      {
        'author': 'User123',
        'content': 'I found this really helpful.',
        'isReply': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar(
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final bool isReply = comments[index]['isReply'];
                      return Padding(
                        padding: EdgeInsets.only(
                          top: SizeScaler.scaleSize(context, 3, 6),
                          bottom: SizeScaler.scaleSize(context, 3, 6),
                          left: isReply ? SizeScaler.scaleSize(context, 17, 34) : SizeScaler.scaleSize(context, 11, 22), // 답글은 6만큼 더 들여쓰기
                          right: SizeScaler.scaleSize(context, 11, 22), // 우측 여백
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: SizeScaler.scaleSize(context, 6, 12),
                                  backgroundColor: Colors.grey,
                                ),
                                SizedBox(width: SizeScaler.scaleSize(context, 3, 6)),
                                Text(
                                  comments[index]['author']!,
                                  style: TextStyle(
                                    fontSize: SizeScaler.scaleSize(context, 6, 12),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: SizeScaler.scaleSize(context, 4, 8)),
                            Text(
                              comments[index]['content']!,
                              style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 6, 12),
                                fontWeight: FontWeight.w200,
                                color: const Color(0xFF353535),
                              ),
                            ),
                            SizedBox(height: SizeScaler.scaleSize(context, 1, 2)),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.reply, size: SizeScaler.scaleSize(context, 10, 20)),
                                  onPressed: () {
                                    // 답글쓰기 기능 추가
                                  },
                                ),
                                Text(
                                  '답글쓰기',
                                  style: TextStyle(
                                    fontSize: SizeScaler.scaleSize(context, 5, 10),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF7E7E7E),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(SizeScaler.scaleSize(context, 16, 32)),
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
                SizedBox(width: SizeScaler.scaleSize(context, 8, 16)),
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
