import 'package:flutter/material.dart';
import 'package:nahollo/screens/diary_screens/diary_user.dart';
import 'package:nahollo/screens/diary_screens/diary_search.dart';
import 'package:nahollo/screens/diary_screens/diary_writing.dart';
import 'package:nahollo/screens/diary_screens/diary_text.dart';
import 'package:nahollo/models/user_model.dart'; // 유저 프로필
import 'package:nahollo/models/diaryPost_model.dart'; // 포스트 모델
import 'package:intl/intl.dart'; // 날짜 포맷
import 'package:nahollo/sizeScaler.dart'; // 크기 조절
import 'package:nahollo/providers/user_provider.dart';
import 'package:http/http.dart' as http; // HTTP 패키지 임포트
import 'dart:convert'; // JSON 파싱을 위해 필요
import 'package:provider/provider.dart'; // Provider 패키지 임포트

class DiaryMain extends StatefulWidget {
  const DiaryMain({super.key});

  @override
  _DiaryMainState createState() => _DiaryMainState();
}

class _DiaryMainState extends State<DiaryMain> {
  int _selectedIndex = 0;

  List<diaryPost_model> topPosts = [];
  List<diaryPost_model> latestPosts = [];
  List<diaryPost_model> followPosts = [];
  List<diaryPost_model> blogPosts = []; // 현재 선택된  방식에 따른 포스트 리스트

  final List<String> _buttonLabels = ['인기순', '최신순', '팔로우'];

  @override
  void initState() {
    super.initState();

    // Provider에서 userId를 가져와서 데이터 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String userId = userProvider.user!.userId;

      print('User ID: $userId');
      fetchData(userId);
    });
  }

void fetchData(String userId) async {
  final url = 'http://10.0.2.2:8000/journal/main'; // 서버 URL
  final response = await http.get(Uri.parse('$url?user_id=$userId'));

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));

    // 데이터가 null이 아닌지 체크
    if (data != null && data['data'] != null) {
      setState(() {
        topPosts = [];
        latestPosts = [];
        followPosts = [];

        // 인기순 포스트 처리
        if (data['data']['top_10'] != null && data['data']['top_10'].isNotEmpty) {
          List<dynamic> topData = data['data']['top_10'];
          for (var postData in topData) {
            diaryPost_model post = diaryPost_model(
              author: postData['USER_ID'],
              authorID: postData['USER_ID'],
              createdAt: DateTime.parse(postData['POST_CREATE']), // 확인: POST_UPDATE에서 created_at으로 변경
              title: postData['POST_NAME'],
              content: postData['POST_CONTENT'] ?? '',
              likes: postData['POST_LIKE'],
              liked: false,
              subjList: [false, false, false, false, false, false, false],
            );
            topPosts.add(post);
          }
        } else {
          print('No top posts available');
        }

        // 최신순 포스트 처리
        if (data['data']['latest_10'] != null && data['data']['latest_10'].isNotEmpty) {
          List<dynamic> latestData = data['data']['latest_10'];
          for (var postData in latestData) {
            diaryPost_model post = diaryPost_model(
              author: postData['USER_ID'],
              authorID: postData['USER_ID'],
              createdAt: DateTime.parse(postData['POST_CREATE']), // 확인: POST_UPDATE에서 created_at으로 변경
              title: postData['POST_NAME'],
              content: postData['POST_CONTENT'] ?? '',
              likes: postData['POST_LIKE'],
              liked: false,
              subjList: [false, false, false, false, false, false, false],
            );
            latestPosts.add(post);
          }
        } else {
          print('No latest posts available');
        }

        // 팔로우 포스트 처리
        if (data['data']['followers_latest'] != null && data['data']['followers_latest'].isNotEmpty) {
          List<dynamic> followData = data['data']['followers_latest'];
          for (var postData in followData) {
            diaryPost_model post = diaryPost_model(
              author: postData['USER_ID'],
              authorID: postData['USER_ID'],
              createdAt: DateTime.parse(postData['POST_CREATE']), // 확인: POST_UPDATE에서 created_at으로 변경
              title: postData['POST_NAME'],
              content: postData['POST_CONTENT'] ?? '',
              likes: postData['POST_LIKE'],
              liked: false,
              subjList: [false, false, false, false, false, false, false],
            );
            followPosts.add(post);
          }
        } else {
          print('No follow posts available');
        }

        // 선택된 정렬 방식에 따라 blogPosts 업데이트
        _updateBlogPosts();
      });
    } else {
      print('Failed to parse data: data or data[\'data\'] is null');
    }
  } else {
    print('Failed to fetch data: ${response.statusCode}');
  }
}

  // 선택된 정렬 방식에 따라 blogPosts 리스트 업데이트
  void _updateBlogPosts() {
    setState(() {
      if (_selectedIndex == 0) {
        blogPosts = topPosts;
      } else if (_selectedIndex == 1) {
        blogPosts = latestPosts;
      } else if (_selectedIndex == 2) {
        blogPosts = followPosts;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: SizeScaler.scaleSize(context, 25),
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                // 커스텀 뒤로가기 아이콘
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: SizeScaler.scaleSize(context, 10),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                // 텍스트 (가운데 정렬)
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      '나홀로일지',
                      style: TextStyle(
                        fontSize: SizeScaler.scaleSize(context, 8),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // 검색 아이콘과 유저 프로필
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 검색 아이콘
                      IconButton(
                        icon: Icon(Icons.search, size: SizeScaler.scaleSize(context, 14)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DiarySearch()),
                          );
                        },
                      ),
                      // 유저 프로필 사진
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiaryUser(authorID: '클라이언트 ID 가져오기'),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: SizeScaler.scaleSize(context, 7.25),
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: SizeScaler.scaleSize(context, 12.325),
                          ),
                        ),
                      ),
                      SizedBox(width: SizeScaler.scaleSize(context, 2)), // 버튼 사이의 여백
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
            height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
          ),
          // 정렬 버튼
          Container(
            padding: EdgeInsets.only(
              left: SizeScaler.scaleSize(context, 11),
              top: SizeScaler.scaleSize(context, 7),
              bottom: SizeScaler.scaleSize(context, 7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(_buttonLabels.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index; // 선택된 버튼의 인덱스 업데이트
                      _updateBlogPosts(); // 선택된 정렬 방식에 따라 blogPosts 업데이트
                    });
                  },
                  child: Container(
                    width: SizeScaler.scaleSize(context, 29),
                    height: SizeScaler.scaleSize(context, 12),
                    margin: EdgeInsets.only(right: SizeScaler.scaleSize(context, 2)),
                    padding: EdgeInsets.symmetric(
                      vertical: SizeScaler.scaleSize(context, 2),
                      horizontal: SizeScaler.scaleSize(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: _selectedIndex == index ? const Color(0xFFE7E7E7) : Colors.white,
                      border: Border.all(color: const Color(0xFF9C9C9C)),
                      borderRadius: BorderRadius.circular(SizeScaler.scaleSize(context, 12)),
                    ),
                    child: Center(
                      child: Text(
                        _buttonLabels[index],
                        style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 5),
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
          // 포스트 리스트
          Expanded(
            child: ListView.separated(
              itemCount: blogPosts.length,
              separatorBuilder: (context, index) => Divider(
                color: const Color(0xFFD9D9D9),
                thickness: SizeScaler.scaleSize(context, 3),
              ),
              itemBuilder: (context, index) {
                final post = blogPosts[index];
                return Container(
                  padding: EdgeInsets.only(
                    left: SizeScaler.scaleSize(context, 13),
                    top: SizeScaler.scaleSize(context, 15),
                    bottom: SizeScaler.scaleSize(context, 18),
                    right: SizeScaler.scaleSize(context, 9),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 왼쪽 칸 (프로필, 제목, 본문 미리보기)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 프로필 사진, 작성자, 시간
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiaryUser(authorID: post.authorID),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: SizeScaler.scaleSize(context, 10),
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: SizeScaler.scaleSize(context, 17),
                                    ),
                                  ),
                                  SizedBox(width: SizeScaler.scaleSize(context, 5)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.author,
                                          style: TextStyle(
                                            fontSize: SizeScaler.scaleSize(context, 8),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          _formatDateTime(post.createdAt),
                                          style: TextStyle(
                                            fontSize: SizeScaler.scaleSize(context, 6),
                                            fontWeight: FontWeight.w300,
                                            color: const Color(0xFF7E7E7E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: SizeScaler.scaleSize(context, 6)),
                            // 제목, 본문 미리보기
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiaryText(
                                      postTitle: post.title,
                                      postContent: post.content,
                                      author: post.author,
                                      authorID: post.authorID,
                                      createdAt: post.createdAt,
                                      subjList: post.subjList,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.title,
                                    style: TextStyle(fontSize: SizeScaler.scaleSize(context, 8)),
                                  ),
                                  SizedBox(height: SizeScaler.scaleSize(context, 4.5)),
                                  Text(
                                    post.getContentPreview(38),
                                    style: TextStyle(
                                      fontSize: SizeScaler.scaleSize(context, 6),
                                      fontWeight: FontWeight.w200,
                                      color: const Color(0xFF7E7E7E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: SizeScaler.scaleSize(context, 8)),
                      // 오른쪽 칸 (이미지)
                      Container(
                        width: SizeScaler.scaleSize(context, 70),
                        height: SizeScaler.scaleSize(context, 70),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(SizeScaler.scaleSize(context, 4)),
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
      floatingActionButton: Container(
        width: SizeScaler.scaleSize(context, 60),
        height: SizeScaler.scaleSize(context, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA526FF), Color(0xFF5D5FF4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(SizeScaler.scaleSize(context, 20)),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DiaryWriting()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: SizeScaler.scaleSize(context, 4)),
              Text(
                '글쓰기',
                style: TextStyle(
                  fontSize: SizeScaler.scaleSize(context, 8),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: SizeScaler.scaleSize(context, 4)),
              const Icon(Icons.edit, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // 작성일 포맷팅 함수
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 1) {
      return DateFormat('yyyy.MM.dd').format(dateTime);
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
