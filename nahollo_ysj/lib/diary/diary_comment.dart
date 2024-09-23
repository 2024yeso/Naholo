// diary_comment.dart
import 'package:flutter/material.dart';
import '../models/diaryComment_model.dart'; // 포스트 모델
import 'package:flutter_application_1/sizeScaler.dart'; // 크기 조절
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = "http://127.0.0.1:8000";

class DiaryComment extends StatefulWidget {
  final String postTitle;

  DiaryComment({required this.postTitle});

  @override
  _DiaryCommentState createState() => _DiaryCommentState();
}

class _DiaryCommentState extends State<DiaryComment> {
  List<diaryComment_model> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final response = await http.get(Uri.parse('$baseUrl/comments?postTitle=${widget.postTitle}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        comments = (data["comments"] as List).map((comment) {
          return diaryComment_model(
            author: comment['NICKNAME'],
            authorID: comment['USER_ID'],
            content: comment['COMMENT_CONTENT'],
          );
        }).toList();
        isLoading = false;
      });
    } else {
      print("Failed to fetch comments: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
      setState(() {
        isLoading = false;
      });
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
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
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
                        SizedBox(height: SizeScaler.scaleSize(context, 5)), // 댓글수와 첫 댓글 사이의 여백
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: SizeScaler.scaleSize(context, 3),
                                horizontal: SizeScaler.scaleSize(context, 11), // 좌우 여백 추가
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
                                      SizedBox(width: SizeScaler.scaleSize(context, 3)),
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
            width: double.infinity, // 화면 넓이
            padding: EdgeInsets.only(bottom: SizeScaler.scaleSize(context, 20)),
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
                  borderRadius: BorderRadius.circular(SizeScaler.scaleSize(context, 27)), // 모서리 둥글게
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '댓글을 남겨주세요',
                    hintStyle: TextStyle(
                        color: const Color(0xFF7C7C7C),
                        fontSize: SizeScaler.scaleSize(context, 7),
                        fontWeight: FontWeight.w200),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: SizeScaler.scaleSize(context, 10)),
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
