// diary_text.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷
import 'diary_comment.dart'; // 나홀로일지 댓글
import 'diary_writing.dart';
import 'diary_user.dart';
import 'package:nahollo/sizeScaler.dart';

String userName = "시금치"; // 현재 유저의 닉네임
final List<String> subjects = [
  '# 혼캎',
  '# 혼영',
  '# 혼놀',
  '# 혼밥',
  '# 혼박',
  '# 혼술',
  '# 기타'
];

class DiaryText extends StatefulWidget {
  final String postTitle;
  final String postContent;
  final String author; // 작성자 이름
  final String authorID;
  final DateTime createdAt; // 작성 시간
  final List<bool> subjList;

  DiaryText({
    required this.postTitle,
    required this.postContent,
    required this.author,
    required this.authorID,
    required this.createdAt,
    required this.subjList,
  });

  @override
  _DiaryTextState createState() => _DiaryTextState();
}

class _DiaryTextState extends State<DiaryText> {
  bool isLiked = false; // 좋아요 상태
  int likeCount = 10; // 좋아요 수 (예시)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              toolbarHeight: SizeScaler.scaleSize(context, 25),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: SizeScaler.scaleSize(context, 10),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Center(
                child: Text('일지 상세 보기',
                    style: TextStyle(
                      fontSize: SizeScaler.scaleSize(context, 8),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
              ),
              actions: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.share,
                          size: SizeScaler.scaleSize(context, 10)),
                      onPressed: () {
                        // 공유 기능 추가
                      },
                    ),
                    SizedBox(width: SizeScaler.scaleSize(context, 2)),
                  ],
                ),
              ],
            ),
            Container(
              color: const Color(0xFFBABABA),
              height: SizeScaler.scaleSize(context, 0.5),
            ),
            Padding(
              padding: EdgeInsets.all(SizeScaler.scaleSize(context, 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      // 유저 프로필 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DiaryUser(authorID: widget.authorID), // DiaryUser로 이동
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: SizeScaler.scaleSize(context, 10),
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: SizeScaler.scaleSize(context, 4)), // 글쓴이 프로필의 사진과 이름 간격
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.author,
                                style: TextStyle(
                                    fontSize: SizeScaler.scaleSize(context, 8),
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                _formatDateTimeRelative(widget.createdAt),
                                style: TextStyle(
                                    fontSize: SizeScaler.scaleSize(context, 6),
                                    fontWeight: FontWeight.w300,
                                    color: const Color(0xFF7E7E7E)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert,
                              size: SizeScaler.scaleSize(context, 10)),
                          onPressed: () {
                            _showOptions(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: SizeScaler.scaleSize(context, 12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.postTitle,
                        style: TextStyle(
                            fontSize: SizeScaler.scaleSize(context, 10),
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: SizeScaler.scaleSize(context, 2)),
                      Text(
                        _formatDateTimeAbsolute(widget.createdAt),
                        style: TextStyle(
                            fontSize: SizeScaler.scaleSize(context, 5),
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF7E7E7E)),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeScaler.scaleSize(context, 10)),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: const Color(0xFFBABABA),
                          height: SizeScaler.scaleSize(context, 0.5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeScaler.scaleSize(context, 13)),

                  // 그라데이션 버튼 추가
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DiaryWriting(), // DiaryWriting 페이지로 이동
                          ),
                        );
                      },
                      child: Container(
                        width: SizeScaler.scaleSize(context, 160),
                        height: SizeScaler.scaleSize(context, 24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFCA75FA),
                              Color(0xFF9B9FF1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                              SizeScaler.scaleSize(context, 7)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: SizeScaler.scaleSize(context, 10)),
                              child: Text(
                                "일지쓰고 캐릭터 성장시키자!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: SizeScaler.scaleSize(context, 6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  right: SizeScaler.scaleSize(context, 10)),
                              child: Text(
                                "오늘 하루 기록하러 가기 >",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: SizeScaler.scaleSize(context, 4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeScaler.scaleSize(context, 25)),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal:
                            SizeScaler.scaleSize(context, 7)), // 본문 좌우 여백
                    child: Text(
                      widget.postContent,
                      style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 7),
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(SizeScaler.scaleSize(context, 5)),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: SizeScaler.scaleSize(context, 5)),
                      child: Wrap(
                        spacing:
                            SizeScaler.scaleSize(context, -5), // 태그 간의 가로 간격
                        runSpacing:
                            SizeScaler.scaleSize(context, 2), // 태그 간의 세로 간격
                        children: widget.subjList
                            .asMap()
                            .entries
                            .where((entry) => entry.value) // `true`인 인덱스만 필터링
                            .map((entry) => Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeScaler.scaleSize(context, 4)),
                                  child: Text(
                                    subjects[entry.key], // 해당 인덱스의 태그 출력
                                    style: TextStyle(
                                        fontSize:
                                            SizeScaler.scaleSize(context, 7),
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFA3A3A3)),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeScaler.scaleSize(context, 5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: SizeScaler.scaleSize(context, 2)),
                        child: Row(
                          children: [
                            IconButton(
                              iconSize: SizeScaler.scaleSize(context, 10),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.black,
                                size: SizeScaler.scaleSize(context, 10),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isLiked) {
                                    likeCount--;
                                  } else {
                                    likeCount++;
                                  }
                                  isLiked = !isLiked;
                                });
                              },
                            ),
                            Text(
                              '$likeCount',
                              style: TextStyle(
                                  fontSize: SizeScaler.scaleSize(context, 5),
                                  fontWeight: FontWeight.w300),
                            ),
                            IconButton(
                              icon: Icon(Icons.comment,
                                  size: SizeScaler.scaleSize(context, 10)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiaryComment(
                                        postTitle: widget.postTitle),
                                  ),
                                );
                              },
                            ),
                            Text(
                              '5', // 댓글 개수 (제대로 구현 안 됨)
                              style: TextStyle(
                                  fontSize: SizeScaler.scaleSize(context, 5),
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 옵션 버튼을 눌렀을 때 나타날 기능을 정의합니다.
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: userName == widget.author
              ? [
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: const Text('수정하기'),
                    onTap: () {
                      // 수정 기능
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: const Text('삭제하기'),
                    onTap: () {
                      // 삭제 기능
                      Navigator.pop(context);
                    },
                  ),
                ]
              : [
                  ListTile(
                    leading: Icon(Icons.block),
                    title: const Text('차단하기'),
                    onTap: () {
                      // 차단 기능
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.report),
                    title: const Text('신고하기'),
                    onTap: () {
                      // 신고 기능
                      Navigator.pop(context);
                    },
                  ),
                ],
        );
      },
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
      // 1분 미만일 경우 방금 전으로 표시
      return '방금 전';
    }
  }

  // 절대적 시간 포맷팅 함수
  String _formatDateTimeAbsolute(DateTime dateTime) {
    return DateFormat('yyyy.MM.dd. HH:mm').format(dateTime);
  }
}
