// diary_comment.dart
import 'package:flutter/material.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/models/diaryComment_model.dart';
import 'package:nahollo/sizeScaler.dart'; // 크기 조절
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // Provider 패키지 임포트
import 'package:nahollo/providers/user_provider.dart';

class DiaryComment extends StatefulWidget {
  final String postTitle;
  final int postId;

  const DiaryComment(
      {super.key, required this.postTitle, required this.postId});

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

  // 서버로부터 댓글을 가져오는 함수
  Future<void> fetchComments() async {
    final url = '${Api.baseUrl}/journal/get_comments?post_id=${widget.postId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> commentsData = data['comments'];

        setState(() {
          comments = commentsData
              .map((json) => diaryComment_model.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        print('Failed to fetch comments: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글을 가져오는데 실패했습니다.')),
        );
      }
    } catch (e) {
      print('Error fetching comments: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 가져오는데 오류가 발생했습니다.')),
      );
    }
  }

Future<void> addComment(String content) async {
  const url = '${Api.baseUrl}/journal/add_comment'; // 올바른 엔드포인트
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.user?.userId ?? 'unknown';
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'POST_ID': widget.postId,            // 서버에서 기대하는 'POST_ID'
        'USER_ID': userId,                   // 서버에서 기대하는 'USER_ID'
        'COMMENT_CONTENT': content,          // 서버에서 기대하는 'COMMENT_CONTENT'
      }),
    );

    if (response.statusCode == 200) {
      // 댓글 추가 성공 시, 다시 댓글을 가져옵니다.
      await fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글이 추가되었습니다!')),
      );
    } else {
      print('Failed to add comment: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 추가하는데 실패했습니다.')),
      );
    }
  } catch (e) {
    print('Error adding comment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('댓글을 추가하는데 오류가 발생했습니다.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: SizeScaler.scaleSize(context, 32),
        automaticallyImplyLeading: false, // 기본 뒤로가기 화살표 제거
        title: Row(
          children: [
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
            Expanded(
              flex: 10,
              child: Center(
                child: Text(
                  '댓글',
                  style: TextStyle(
                    fontSize: SizeScaler.scaleSize(context, 8.8),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
                : comments.isEmpty
                    ? const Center(child: Text('댓글이 없습니다.'))
                    : ListView.builder(
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
                                      child: Text(
                                        comments[index].author[0], // 첫 글자 표시
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            SizeScaler.scaleSize(context, 3)),
                                    Text(
                                      comments[index].author,
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
                                  comments[index].content,
                                  style: TextStyle(
                                    fontSize: SizeScaler.scaleSize(context, 6),
                                    fontWeight: FontWeight.w200,
                                    color: const Color(0xFF353535),
                                  ),
                                ),
                                SizedBox(
                                    height: SizeScaler.scaleSize(context, 1)),
                                /* Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.reply,
                                          size: SizeScaler.scaleSize(
                                              context, 10)),
                                      onPressed: () {
                                        // 답글쓰기 기능 추가 (추후 구현)
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
                                ), */
                                const Divider(), // 각 댓글 구분선
                              ],
                            ),
                          );
                        },
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
                  width: SizeScaler.scaleSize(context, 175),
                  height: SizeScaler.scaleSize(context, 29),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(
                        SizeScaler.scaleSize(context, 15)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
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
                          String content = _commentController.text.trim();
                          if (content.isNotEmpty) {
                            addComment(content);
                            _commentController.clear();
                          }
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

  // 댓글 입력을 위한 컨트롤러
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
