// diary_main.dart
import 'package:flutter/material.dart';
import 'diary_text.dart'; // 나홀로일지 글 상세보기
import 'diary_search.dart'; // 나홀로일지 검색
import 'diary_writing.dart'; // 나홀로일지 글쓰기
import 'diary_user.dart'; // 유저 프로필
import 'diaryclass_DiaryPostList.dart'; // 포스트 모델
import 'package:intl/intl.dart'; // 날짜 포맷
import 'package:flutter_application_1/size_scaler.dart'; // 크기 조절

class DiaryMain extends StatefulWidget {
  @override
  _DiaryMainState createState() => _DiaryMainState();
}

class _DiaryMainState extends State<DiaryMain> {
  // 현재 선택된 버튼을 관리하기 위한 변수
  int _selectedIndex = 0;

  // 버튼 라벨
  final List<String> _buttonLabels = ['인기순', '최신순', '구독'];

  @override
  Widget build(BuildContext context) {
    // 샘플 데이터
    final List<DiaryPostList> blogPosts = [
      DiaryPostList(
        author: '시금치',
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        title: '드디어 레고 조립을 완료하였습니다.',
        content: '저의 취미인 레고 조립.. 그동안 시간이 없어서 많이 못했었는데요! 약 반년 걸린...',
      ),
      DiaryPostList(
        author: '바나나',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        title: '제목',
        content: '미리보기 글...',
      ),
      DiaryPostList(
        author: '샐러드',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        title: '자취생 꿀팁 모음',
        content: '안녕하세요! 오늘은 여러분들을 위해 혼놀 꿀팁을 가져와봤습니다! 요즘 같은...',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            title: Center(
              child: Text('나홀로일지', style: TextStyle(
                fontSize: SizeScaler.scaleSize(context, 8.0),
                fontWeight: FontWeight.bold,
                color: Colors.black,)
            ),
            ),
            actions: [
              Row(
                children: [
                  // 검색 페이지로 이동하는 버튼
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiarySearch()),
                      );
                    },
                  ),
                  // 유저 프로필 사진
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryUser(author: '유저이름'), // '유저이름'은 실제 유저 이름으로 변경해야 함
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: SizeScaler.scaleSize(context, 7.25),
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: SizeScaler.scaleSize(context, 2.0)), // 버튼 사이의 여백
                ],
              ),
            ],
          ),
          Container(
            color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
            height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
          ),
          // 정렬 버튼
          Container(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(_buttonLabels.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index; // 선택된 버튼의 인덱스 업데이트
                    });
                  },
                  child: Container(
                    width: SizeScaler.scaleSize(context, 29.0), // 버튼의 가로 길이 설정
                    height: SizeScaler.scaleSize(context, 12.0), // 버튼의 세로 길이 설정
                    margin: EdgeInsets.only(right: SizeScaler.scaleSize(context, 2.0)), // 버튼 사이 간격 설정
                    padding: EdgeInsets.symmetric(vertical: SizeScaler.scaleSize(context, 2.0), horizontal: SizeScaler.scaleSize(context, 4.0)), // 버튼 내부 패딩
                    decoration: BoxDecoration(
                      color: _selectedIndex == index ? const Color(0xFFE7E7E7) : Colors.white, // 선택된 버튼 색상 : 선택되지 않은 버튼 색상
                      border: Border.all(color: const Color(0xFF9C9C9C)), // 테두리 색상
                      borderRadius: BorderRadius.circular(SizeScaler.scaleSize(context, 12.0)), // 모서리 둥글게
                    ),
                    child: Center(
                      child: Text(
                        _buttonLabels[index],
                        style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 5.0), // 버튼 텍스트 폰트 크기 설정
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: blogPosts.length,
              separatorBuilder: (context, index) => Divider(
                color: const Color(0xFFD9D9D9), // 회색 바
                thickness: SizeScaler.scaleSize(context, 3.0), // 글 구분선 두께
              ),
              itemBuilder: (context, index) {
                final post = blogPosts[index];
                return Container(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // 왼쪽 칸
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 프로필 사진, 작성자, 시간
                            GestureDetector(
                              onTap: () {
                                // 유저 프로필 페이지로 이동
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiaryUser(author: post.author), // DiaryUser로 이동
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: SizeScaler.scaleSize(context, 10.0),
                                    backgroundColor: Colors.grey, // 회색 프로필 사진
                                    child: Icon(Icons.person, color: Colors.white), // 기본 아이콘
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(post.author, style: TextStyle(
                                          fontSize: SizeScaler.scaleSize(context, 8.0), 
                                          fontWeight: FontWeight.w600)),
                                        Text(_formatDateTime(post.createdAt), style: TextStyle(
                                          fontSize: SizeScaler.scaleSize(context, 6.0), 
                                          fontWeight: FontWeight.w300,
                                          color: const Color(0xFF7E7E7E))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.0),
                            // 제목, 본문 미리보기
                            GestureDetector(
                              onTap: () {
                                // 포스트 상세 페이지로 이동
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiaryText(
                                      postTitle: post.title,
                                      postContent: post.content,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.title, style: TextStyle(
                                    fontSize: SizeScaler.scaleSize(context, 8.0))),
                                  SizedBox(height: 12.0),
                                  Text(post.getContentPreview(50), style: TextStyle(
                                    fontSize: SizeScaler.scaleSize(context, 6.0),
                                    fontWeight: FontWeight.w200,
                                    color: const Color(0xFF7E7E7E))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.0),
                      // 오른쪽 칸 (사진)
                      Container(
                        width: 120.0, // 사진의 가로 길이
                        height: 120.0, // 사진의 세로 길이
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // 회색 상자
                          borderRadius: BorderRadius.circular(8.0), // 둥근 모서리
                        ),
                        child: Center(
                          child: Icon(Icons.image, color: Colors.grey[700], size: 50.0), // 이미지 아이콘
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 글쓰기 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryWriting()),
          );
        },
        child: Icon(Icons.edit),
        tooltip: 'Write a Post',
      ),
    );
  }

  // 작성일 포맷팅 함수
  String _formatDateTime(DateTime dateTime) {
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
}

// 데이터를 불러오는 코드 추가

// 불러온 데이터에서 본문 미리보기 텍스트를 생성하는 코드 추가

// 불러온 데이터를 보여주도록 코드를 수정

// 사진 여부를 판단해서 제목과 미리보기 텍스트 박스 크기를 늘릴 필요가 있음