// diary_comment.dart
import 'package:flutter/material.dart';
import 'package:nahollo/models/diaryComment_model.dart';
import 'package:nahollo/sizeScaler.dart'; // 크기 조절

class DiaryComment extends StatelessWidget {
  final String postTitle;

  DiaryComment({required this.postTitle});

  @override
  Widget build(BuildContext context) {
    // 샘플 댓글 데이터
// 샘플 데이터 추가
    final List<diaryComment_model> comments = [
      diaryComment_model(
        author: '홍길동',
        authorID: 'user123',
        content: '이 일기 정말 감명 깊게 읽었어요!',
      ),
      diaryComment_model(
        author: '김철수',
        authorID: 'user456',
        content: '저도 비슷한 경험을 했어요. 공감합니다!',
      ),
      diaryComment_model(
        author: '이영희',
        authorID: 'user789',
        content: '다음 일기도 기대됩니다 :)',
      ),
      diaryComment_model(
        author: '박민수',
        authorID: 'user101',
        content: '좋은 글 감사합니다. 저도 글을 써보고 싶네요.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: SizeScaler.scaleSize(context, 25),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.black, size: SizeScaler.scaleSize(context, 10)),
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
          SizedBox(width: SizeScaler.scaleSize(context, 28))
        ], // 화면 중앙 맞추기 위한 여백 추가
      ),
      body: Column(
        children: [
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
                      top: SizeScaler.scaleSize(
                        context,
                        8,
                      ),
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
                    height: SizeScaler.scaleSize(context, 5),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: SizeScaler.scaleSize(context, 3),
                          horizontal: SizeScaler.scaleSize(context, 11),
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
                                  comments[index].author,
                                  style: TextStyle(
                                    fontSize: SizeScaler.scaleSize(context, 6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: SizeScaler.scaleSize(context, 4)),
                            Text(
                              comments[index].content,
                              style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 6),
                                fontWeight: FontWeight.w200,
                                color: const Color(0xFF353535),
                              ),
                            ),
                            SizedBox(height: SizeScaler.scaleSize(context, 1)),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.reply,
                                      size: SizeScaler.scaleSize(context, 10)),
                                  onPressed: () {
                                    // 답글쓰기 기능 추가
                                  },
                                ),
                                Text(
                                  '답글쓰기',
                                  style: TextStyle(
                                    fontSize: SizeScaler.scaleSize(context, 5),
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
            width: double.infinity,
            padding: EdgeInsets.only(bottom: SizeScaler.scaleSize(context, 20)),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: Offset(0, SizeScaler.scaleSize(context, -0.1)),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(SizeScaler.scaleSize(context, 7)),
              child: Container(
                  padding: EdgeInsets.all(SizeScaler.scaleSize(context, 2)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    border: Border.all(
                      color: Colors.black,
                      width: SizeScaler.scaleSize(context, 0.2),
                    ),
                    borderRadius: BorderRadius.circular(
                        SizeScaler.scaleSize(context, 27)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '댓글을 남겨주세요',
                            hintStyle: TextStyle(
                              color: const Color(0xFF7C7C7C),
                              fontSize: SizeScaler.scaleSize(context, 7),
                              fontWeight: FontWeight.w200,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: SizeScaler.scaleSize(context, 10)),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // 게시 버튼을 눌렀을 때의 동작 추가
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.transparent),
                          minimumSize: WidgetStateProperty.all(Size(
                              SizeScaler.scaleSize(context, 30),
                              SizeScaler.scaleSize(context, 20))),
                        ),
                        child: Text(
                          '게시',
                          style: TextStyle(
                            fontSize: SizeScaler.scaleSize(context, 7),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7C7C7C),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
