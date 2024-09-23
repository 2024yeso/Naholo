// diary_main.dart
import 'package:flutter/material.dart';
import 'diary_text.dart'; // 나홀로일지 글 상세보기
import 'diary_search.dart'; // 나홀로일지 검색
import 'diary_writing.dart'; // 나홀로일지 글쓰기
import 'diary_user.dart'; // 유저 프로필
import '../models/diaryPost_model.dart'; // 포스트 모델
import 'package:intl/intl.dart'; // 날짜 포맷
import 'package:flutter_application_1/sizeScaler.dart'; // 크기 조절
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = "http://127.0.0.1:8000";

class DiaryMain extends StatefulWidget {
  @override
  _DiaryMainState createState() => _DiaryMainState();
}

class _DiaryMainState extends State<DiaryMain> {
  int _selectedIndex = 0;

  List<diaryPost_model> blogPosts = [];

  final List<String> _buttonLabels = ['인기순', '최신순', '팔로우'];

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // 초기 데이터 로드
  }

  Future<void> _fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/journal/main'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (_selectedIndex == 0) { // 인기순
        blogPosts = (data["data"]["top_10"] as List)
            .map((post) => diaryPost_model(
                  author: post['USER_ID'],
                  authorID: post['USER_ID'],
                  createdAt: DateTime.parse(post['POST_UPDATE']),
                  title: post['POST_NAME'],
                  content: post['POST_CONTENT'],
                  likes: post['POST_LIKE'],
                  liked: post['POST_LIKED'],
                ))
            .toList();
      } else if (_selectedIndex == 1) { // 최신순
        blogPosts = (data["data"]["latest_10"] as List)
            .map((post) => diaryPost_model(
                  author: post['USER_ID'],
                  authorID: post['USER_ID'],
                  createdAt: DateTime.parse(post['POST_UPDATE']),
                  title: post['POST_NAME'],
                  content: post['POST_CONTENT'],
                  likes: post['POST_LIKE'],
                  liked: false, // post['POST_LIKED'],
                ))
            .toList();
      } else if (_selectedIndex == 2) {
        blogPosts = (data["data"]["subscribed_posts"] as List) // 수정 : 팔로우한 유저 중 최신순으로 정렬해서 받을 수 있어야 함
            .map((post) => diaryPost_model(
                  author: post['USER_ID'], // 수정 : 유저 닉네임 데이터 필요함
                  authorID: post['USER_ID'],
                  createdAt: DateTime.parse(post['POST_UPDATE']), // 수정 : 수정시간 작성시간 어떻게 할 지 정해야 함
                  title: post['POST_NAME'],
                  content: post['POST_CONTENT'],
                  likes: post['POST_LIKE'],
                  liked: false, // post['POST_LIKED'], // 수정 : 유저가 좋아요 눌렀는 지 여부 필요함
                ))
            .toList();
      }
      setState(() {}); // 상태 업데이트
    } else {
      throw Exception('Failed to load posts');
    }
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
            title: Center(
              child: Text('나홀로일지',
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
                    icon: Icon(Icons.search, size: SizeScaler.scaleSize(context, 148)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiarySearch()),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryUser(
                              author: '유저이름'),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: SizeScaler.scaleSize(context, 7.25),
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white, size: SizeScaler.scaleSize(context, 15)),
                    ),
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
          Container(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(_buttonLabels.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index; // 선택된 버튼의 인덱스 업데이트
                      _fetchPosts(); // 데이터 새로 가져오기
                    });
                  },
                  child: Container(
                    width: SizeScaler.scaleSize(context, 29),
                    height: SizeScaler.scaleSize(context, 12),
                    margin: EdgeInsets.only(right: SizeScaler.scaleSize(context, 2)),
                    padding: EdgeInsets.symmetric(vertical: SizeScaler.scaleSize(context, 2), horizontal: SizeScaler.scaleSize(context, 4)),
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? const Color(0xFFE7E7E7)
                          : Colors.white,
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
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiaryUser(
                                        author: post.author),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: SizeScaler.scaleSize(context, 10),
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.person, color: Colors.white, size: SizeScaler.scaleSize(context, 20)),
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(post.author,
                                            style: TextStyle(
                                                fontSize: SizeScaler.scaleSize(context, 8),
                                                fontWeight: FontWeight.w600)),
                                        Text(_formatDateTime(post.createdAt),
                                            style: TextStyle(
                                                fontSize: SizeScaler.scaleSize(context, 6),
                                                fontWeight: FontWeight.w300,
                                                color: const Color(0xFF7E7E7E))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiaryText(
                                      postTitle: post.title,
                                      postContent: post.content,
                                      author: post.author,
                                      createdAt: post.createdAt,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.title,
                                      style: TextStyle(
                                          fontSize: SizeScaler.scaleSize(context, 8))),
                                  SizedBox(height: 12.0),
                                  Text(post.getContentPreview(50),
                                      style: TextStyle(
                                          fontSize: SizeScaler.scaleSize(context, 6),
                                          fontWeight: FontWeight.w200,
                                          color: const Color(0xFF7E7E7E))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Container(
                        width: SizeScaler.scaleSize(context, 62),
                        height: SizeScaler.scaleSize(context, 64),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryWriting()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }
}
