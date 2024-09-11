import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷
import 'diary_comment.dart'; // 나홀로일지 댓글
import 'package:flutter_application_1/size_scaler.dart'; // 크기 조절

class DiaryText extends StatelessWidget {
  final String postTitle;
  final String postContent;
  final String author; // 작성자 이름
  final DateTime createdAt; // 작성 시간

  // 생성자에서 글 제목, 내용, 작성자 이름, 작성 시간을 전달받습니다.
  DiaryText({
    required this.postTitle,
    required this.postContent,
    required this.author,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
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
              child: Text('일지 상세 보기',
                  style: TextStyle(
                    fontSize: SizeScaler.scaleSize(context, 8, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
            ),
            actions: [
              Row(
                children: [
                  // 공유 버튼
                  IconButton(
                    icon: Icon(Icons.share, size: SizeScaler.scaleSize(context, 10, 20)),
                    onPressed: () {
                      // 공유 기능 추가
                      // 이곳에 공유 기능 관련 코드를 추가해야 합니다.
                    },
                  ),
                  SizedBox(
                      width: SizeScaler.scaleSize(context, 2, 4)), // 버튼 사이의 여백
                ],
              ),
            ],
          ),
          Container(
            color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
            height: SizeScaler.scaleSize(context, 0.5, 1), // 구분선 두께
          ),
          Padding(
            padding: EdgeInsets.all(SizeScaler.scaleSize(context, 16, 32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 작성자 프로필 사진, 이름, 작성 시간 표시
                Row(
                  children: [
                    CircleAvatar(
                      radius: SizeScaler.scaleSize(context, 10, 20),
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            author, // 작성자 이름
                            style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 8, 16),
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _formatDateTimeRelative(createdAt), // 작성 시간 (상대적)
                            style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 6, 12),
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF7E7E7E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeScaler.scaleSize(context, 12, 24)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      postTitle, // 글 제목
                      style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 10, 20),
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: SizeScaler.scaleSize(context, 2, 4)),
                    Text(
                      _formatDateTimeAbsolute(createdAt), // 작성 시간 (yyyy.MM.dd. HH:mm 형식)
                      style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 5, 10),
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF7E7E7E)),
                    ),
                  ],
                ),
                SizedBox(height: SizeScaler.scaleSize(context, 10, 20)),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                         color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
                         height: SizeScaler.scaleSize(context, 0.5, 1), // 구분선 두께
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeScaler.scaleSize(context, 20, 40)),
                // 글 내용 표시
                Text(
                  postContent,
                  style: TextStyle(
                      fontSize: SizeScaler.scaleSize(context, 7, 14),
                      fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 20),
                // 댓글 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DiaryComment(postTitle: postTitle),
                      ),
                    );
                  },
                  child: Text('View Comments'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 상대적 시간 포맷팅 함수
  String _formatDateTimeRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 1) {
      // 24시간 이상 경과 시 yyyy.MM.dd 포맷으로 표시
      return DateFormat('yyyy.MM.dd').format(dateTime);
    } else if (difference.inHours >= 1) {
      // 1시간 이상 경과 시 몇 시간 전으로 표시
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes >= 1) {
      // 1분 이상 경과 시 몇 분 전으로 표시
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  // 절대적 시간 포맷팅 함수 (yyyy.MM.dd. HH:mm 형식)
  String _formatDateTimeAbsolute(DateTime dateTime) {
    return DateFormat(' yyyy.MM.dd. HH:mm').format(dateTime);
  }
}
