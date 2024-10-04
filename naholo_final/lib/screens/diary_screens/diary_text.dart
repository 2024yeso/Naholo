// diary_text.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷
import 'package:nahollo/api/api.dart';
import 'diary_comment.dart'; // 나홀로일지 댓글
import 'diary_writing.dart';
import 'diary_user.dart';
import 'package:nahollo/sizeScaler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // UserProvider 사용
import 'package:nahollo/providers/user_provider.dart'; // UserProvider 임포트

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
  final int postid; // POST_ID
  final String postTitle;
  final String postContent;
  final String author; // 작성자 이름
  final String authorID;
  final DateTime createdAt; // 작성 시간
  final List<bool> subjList;
  final List<dynamic> images;

  const DiaryText({
    super.key,
    required this.postid,
    required this.postTitle,
    required this.postContent,
    required this.author,
    required this.authorID,
    required this.createdAt,
    required this.subjList,
    required this.images,
  });

  @override
  _DiaryTextState createState() => _DiaryTextState();
}

class _DiaryTextState extends State<DiaryText> {
  bool isLiked = false; // 좋아요 상태
  int likeCount = 0; // 좋아요 수
  int commentCount = 0; // 댓글 수
  bool isLoading = true; // 로딩 상태

  String currentUserId = ''; // 현재 사용자 ID
  String userName = ''; // 현재 사용자 이름

  @override
  void initState() {
    super.initState();
    // 페이지가 열릴 때 데이터를 가져옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      currentUserId = userProvider.user?.userId ?? 'unknown';
      userName = userProvider.user?.nickName ?? 'Unknown'; // 'nickName' 사용
      fetchPostDetails();
    });
  }

// 서버로부터 좋아요 수와 댓글 수를 가져오는 함수
  Future<void> fetchPostDetails() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId ?? 'unknown'; // 현재 사용자 ID 가져오기

    final url =
        '${Api.baseUrl}/journal/post_details?post_id=${widget.postid}&user_id=$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          likeCount = data['likes'] ?? 0;
          commentCount = data['comments'] ?? 0;
          isLiked = data['liked'] ?? false; // 서버에서 좋아요 상태 반영
          isLoading = false;
        });
      } else {
        print('Failed to fetch post details: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 정보를 가져오는데 실패했습니다.')),
        );
      }
    } catch (e) {
      print('Error fetching post details: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시물 정보를 가져오는데 오류가 발생했습니다.')),
      );
    }
  }

  // 좋아요 추가 요청
  Future<void> likePost() async {
    const url = '${Api.baseUrl}/journal/like_post';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'post_id': widget.postid, 'user_id': currentUserId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          likeCount++;
          isLiked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('좋아요를 눌렀습니다!')),
        );
      } else {
        print('Failed to like post: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('좋아요를 누르는데 실패했습니다.')),
        );
      }
    } catch (e) {
      print('Error liking post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요를 누르는데 오류가 발생했습니다.')),
      );
    }
  }

  // 좋아요 취소 요청
  Future<void> unlikePost() async {
    const url = '${Api.baseUrl}/journal/unlike_post';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'post_id': widget.postid, 'user_id': currentUserId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          likeCount--;
          isLiked = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('좋아요를 취소했습니다.')),
        );
      } else {
        print('Failed to unlike post: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('좋아요를 취소하는데 실패했습니다.')),
        );
      }
    } catch (e) {
      print('Error unliking post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요를 취소하는데 오류가 발생했습니다.')),
      );
    }
  }

  // 게시물 삭제 요청
  Future<void> _deletePost() async {
    const url = '${Api.baseUrl}/journal/delete_post';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'post_id': widget.postid, 'user_id': currentUserId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 삭제되었습니다.')),
        );
        Navigator.pop(context); // 이전 페이지로 돌아가기
      } else {
        print('Failed to delete post: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 삭제에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시물 삭제에 오류가 발생했습니다.')),
      );
    }
  }

  // 삭제 확인 다이얼로그
  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게시물 삭제'),
          content: const Text('정말 이 게시물을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePost();
              },
            ),
          ],
        );
      },
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
                    leading: const Icon(Icons.edit),
                    title: const Text('수정하기'),
                    onTap: () {
                      // 수정 기능
                      Navigator.pop(context);
                      // 수정 페이지로 이동하거나 수정 다이얼로그 열기
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('삭제하기'),
                    onTap: () {
                      // 삭제 기능
                      Navigator.pop(context);
                      _confirmDeletion(context);
                    },
                  ),
                ]
              : [
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text('차단하기'),
                    onTap: () {
                      // 차단 기능
                      Navigator.pop(context);
                      // 차단 로직 추가
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.report),
                    title: const Text('신고하기'),
                    onTap: () {
                      // 신고 기능
                      Navigator.pop(context);
                      // 신고 로직 추가
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : SingleChildScrollView(
              child: Column(
                children: [
                  AppBar(
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
                              '일지 상세 보기',
                              style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 8.8),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: Icon(
                              Icons.share,
                              size: SizeScaler.scaleSize(context, 10),
                            ),
                            onPressed: () {
                              // 공유 기능 추가 (예: 공유 패키지 사용)
                            },
                          ),
                        ),
                      ],
                    ),
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
                            /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiaryUser(),
                              ),
                            ); */
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: SizeScaler.scaleSize(context, 10),
                                backgroundColor: Colors.grey,
                                child: const Icon(Icons.person,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                  width: SizeScaler.scaleSize(
                                      context, 4)), // 글쓴이 프로필의 사진과 이름 간격
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.author,
                                      style: TextStyle(
                                        fontSize:
                                            SizeScaler.scaleSize(context, 8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _formatDateTimeRelative(widget.createdAt),
                                      style: TextStyle(
                                        fontSize:
                                            SizeScaler.scaleSize(context, 6),
                                        fontWeight: FontWeight.w300,
                                        color: const Color(0xFF7E7E7E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  size: SizeScaler.scaleSize(context, 10),
                                ),
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
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: SizeScaler.scaleSize(context, 2)),
                            Text(
                              _formatDateTimeAbsolute(widget.createdAt),
                              style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 5),
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF7E7E7E),
                              ),
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
                                  builder: (context) => const DiaryWriting(),
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
                                  SizeScaler.scaleSize(context, 7),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: SizeScaler.scaleSize(context, 10),
                                    ),
                                    child: Text(
                                      "일지쓰고 캐릭터 성장시키자!",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            SizeScaler.scaleSize(context, 6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: SizeScaler.scaleSize(context, 10),
                                    ),
                                    child: Text(
                                      "오늘 하루 기록하러 가기 >",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            SizeScaler.scaleSize(context, 4),
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

                        // 이미지 슬라이더 추가
                        if (widget.images.isNotEmpty) ...[
                          SizedBox(
                            height: SizeScaler.scaleSize(
                                context, 100), // 높이를 고정하여 슬라이더 높이 일정
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: SizeScaler.scaleSize(
                                      context, 5)), // 좌우 패딩 설정
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.images.length,
                                itemBuilder: (context, index) {
                                  try {
                                    final decodedImage =
                                        base64Decode(widget.images[index]);
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeScaler.scaleSize(context, 5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            SizeScaler.scaleSize(context, 7)),
                                        child: Image.memory(
                                          decodedImage,
                                          height: SizeScaler.scaleSize(
                                              context, 90), // 고정된 너비 설정
                                          fit: BoxFit
                                              .fitHeight, // 이미지 비율을 유지하며 잘리지 않게 표시
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    print('Error decoding image: $e');
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeScaler.scaleSize(context, 5),
                                      ),
                                      child: Container(
                                        width:
                                            SizeScaler.scaleSize(context, 100),
                                        height:
                                            SizeScaler.scaleSize(context, 100),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                              SizeScaler.scaleSize(context, 7)),
                                        ),
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.red),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: SizeScaler.scaleSize(context, 25)),
                        ],

                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: SizeScaler.scaleSize(context, 7),
                          ), // 본문 좌우 여백
                          child: Text(
                            widget.postContent,
                            style: TextStyle(
                              fontSize: SizeScaler.scaleSize(context, 7),
                              fontWeight: FontWeight.w300,
                            ),
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
                              left: SizeScaler.scaleSize(context, 5),
                            ),
                            child: Wrap(
                              spacing: SizeScaler.scaleSize(
                                  context, -5), // 태그 간의 가로 간격
                              runSpacing: SizeScaler.scaleSize(
                                  context, 2), // 태그 간의 세로 간격
                              children: widget.subjList
                                  .asMap()
                                  .entries
                                  .where((entry) =>
                                      entry.value) // `true`인 인덱스만 필터링
                                  .map((entry) => Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              SizeScaler.scaleSize(context, 4),
                                        ),
                                        child: Text(
                                          subjects[entry.key], // 해당 인덱스의 태그 출력
                                          style: TextStyle(
                                            fontSize: SizeScaler.scaleSize(
                                                context, 7),
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFA3A3A3),
                                          ),
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
                                left: SizeScaler.scaleSize(context, 2),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    iconSize: SizeScaler.scaleSize(context, 10),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          isLiked ? Colors.red : Colors.black,
                                      size: SizeScaler.scaleSize(context, 10),
                                    ),
                                    onPressed: () async {
                                      if (isLiked) {
                                        await unlikePost();
                                      } else {
                                        await likePost();
                                      }
                                    },
                                  ),
                                  Text(
                                    '$likeCount',
                                    style: TextStyle(
                                      fontSize:
                                          SizeScaler.scaleSize(context, 5),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.comment,
                                      size: SizeScaler.scaleSize(context, 10),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DiaryComment(
                                            postTitle: widget.postTitle,
                                            postId: widget.postid,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Text(
                                    '$commentCount', // 댓글 수 표시
                                    style: TextStyle(
                                      fontSize:
                                          SizeScaler.scaleSize(context, 5),
                                      fontWeight: FontWeight.w300,
                                    ),
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
}
