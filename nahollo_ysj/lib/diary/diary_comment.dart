// diary_comment.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/size_scaler.dart'; // 크기 조절

class DiaryComment extends StatelessWidget {
  final String postTitle;

  DiaryComment({required this.postTitle});

  @override
  Widget build(BuildContext context) {
    // 샘플 댓글 데이터
    final List<Map<String, String>> comments = [
      {
        'author': 'JohnDoe',
        'content': 'Great post!',
      },
      {
        'author': 'JaneSmith',
        'content': 'Very informative.',
      },
      {
        'author': 'User123',
        'content': 'I found this really helpful.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: SizeScaler.scaleSize(context, 25),
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Colors.black,
                  size: SizeScaler.scaleSize(context, 10)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Center(
              child: Text(
                '댓글',
                style: TextStyle(
                  fontSize: SizeScaler.scaleSize(context, 8),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            actions: [
              SizedBox(width: SizeScaler.scaleSize(context, 20))
            ], // 화면 중앙 맞추기 위한 여백 추가
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
                    height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: SizeScaler.scaleSize(context, 8),
                      left: SizeScaler.scaleSize(context, 12),
                      right: SizeScaler.scaleSize(context, 12),
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
                  SizedBox(
                      height: SizeScaler.scaleSize(
                          context, 5)), // 댓글수와 첫 댓글 사이의 여백
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: SizeScaler.scaleSize(context, 3),
                          horizontal:
                              SizeScaler.scaleSize(context, 11), // 좌우 여백 추가
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: SizeScaler.scaleSize(context, 6),
                                  backgroundColor: Colors.grey,
                                ),
                                SizedBox(
                                    width: SizeScaler.scaleSize(context, 3)),
                                Text(
                                  comments[index]['author']!,
                                  style: TextStyle(
                                    fontSize:
                                        SizeScaler.scaleSize(context, 6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: SizeScaler.scaleSize(context, 4)),
                            Text(
                              comments[index]['content']!,
                              style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 6),
                                fontWeight: FontWeight.w200,
                                color: const Color(0xFF353535),
                              ),
                            ),
                            SizedBox(
                                height: SizeScaler.scaleSize(context, 1)),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.reply,
                                      size: SizeScaler.scaleSize(
                                          context, 10)),
                                  onPressed: () {
                                    // 답글쓰기 기능 추가
                                  },
                                ),
                                Text(
                                  '답글쓰기',
                                  style: TextStyle(
                                    fontSize:
                                        SizeScaler.scaleSize(context, 5),
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
          Container(
            width: double.infinity, // 화면 넓이
            padding:
                EdgeInsets.only(bottom: SizeScaler.scaleSize(context, 20)),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: Offset(0, 2), // 상단에만 그림자
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(SizeScaler.scaleSize(context, 7)),
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  border: Border.all(
                    color: Colors.black,
                    width: SizeScaler.scaleSize(context, 0.2), // 테두리 두께 설정
                  ),
                  borderRadius: BorderRadius.circular(
                      SizeScaler.scaleSize(context, 27)), // 모서리 둥글게
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '댓글을 남겨주세요',
                    hintStyle: TextStyle(
                        color: const Color(0xFF7C7C7C),
                        fontSize: SizeScaler.scaleSize(context, 7),
                        fontWeight: FontWeight.w200),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: SizeScaler.scaleSize(context, 10)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 답글 기능 구현
// 글쓴이 표시 구현