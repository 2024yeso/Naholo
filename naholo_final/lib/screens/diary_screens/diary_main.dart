// main.dart

import 'package:flutter/material.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/screens/diary_screens/diary_user.dart';
import 'package:nahollo/screens/diary_screens/diary_search.dart';
import 'package:nahollo/screens/diary_screens/diary_writing.dart';
import 'package:nahollo/screens/diary_screens/diary_text.dart';
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
  List<diaryPost_model> blogPosts = []; // Posts to display

  final List<String> _buttonLabels = ['인기순', '최신순', '팔로우'];

  bool visible = true; // Show the top section initially
  bool isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();

    // Fetch user ID from Provider and request data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String userId = userProvider.user!.userId;

      print('User ID: $userId');
      fetchData(userId);
    });
  }

  void printTopPosts(Map<String, dynamic> data) {
    // data["data"]["top_10"]이 null이 아니고, 빈 리스트가 아닌 경우에만 처리
    if (data["data"]["top_10"] != null && data["data"]["top_10"].isNotEmpty) {
      // top_10 리스트를 반복하여 각 항목 출력
      for (var i = 0; i < data["data"]["top_10"].length; i++) {
        var post = data["data"]["top_10"][i];
        print('Post ${i + 1}');
        print('POST_ID: ${post["POST_ID"]}');
        print('USER_ID: ${post["USER_ID"]}');
        print('POST_NAME: ${post["POST_NAME"]}');
        print('POST_CONTENT: ${post["POST_CONTENT"]}');
        print('POST_CREATE: ${post["POST_CREATE"]}');
        print('POST_LIKE: ${post["POST_LIKE"]}');
        print('liked: ${post["liked"]}');
        print('USER_IMAGE: ${post["USER_IMAGE"]}');
        print('Images: ${post["images"]}');
        print('Subject List: ${post["subjList"]}');
        print('--------------------'); // 구분선 출력
      }
    } else {
      print('No top posts available.');
    }
  }

  void fetchData(String userId) async {
    const url = '${Api.baseUrl}/journal/main'; // 서버 URL
    try {
      final response = await http.get(Uri.parse('$url?user_id=$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('전체 데이터: $data'); // 전체 데이터 로그

        // 데이터가 null이 아닌지 체크
        if (data != null && data['data'] != null) {
          setState(() {
            topPosts = [];
            latestPosts = [];
            followPosts = [];

            // 인기순 포스트 처리
            if (data['data']['top_10'] != null &&
                data['data']['top_10'].isNotEmpty) {
              List<dynamic> topData = data['data']['top_10'];
              topPosts = parsePosts(topData);
              print('Top posts count: ${topPosts.length}');
              for (int i = 0; i < data["data"]["top_10"].length; i++) {
                print(data["data"]["top_10"][i]);
              }
            } else {
              print('No top posts available');
            }

            // 최신순 포스트 처리
            if (data['data']['latest_10'] != null &&
                data['data']['latest_10'].isNotEmpty) {
              List<dynamic> latestData = data['data']['latest_10'];
              latestPosts = parsePosts(latestData);
              print('Latest posts count: ${latestPosts.length}');
            } else {
              print('No latest posts available');
            }

            // 팔로우 포스트 처리
            if (data['data']['followers_latest'] != null &&
                data['data']['followers_latest'].isNotEmpty) {
              List<dynamic> followData = data['data']['followers_latest'];
              followPosts = parsePosts(followData);
              print('Follow posts count: ${followPosts.length}');
              printTopPosts(data);
            } else {
              print('No follow posts available');
            }

            // 선택된 정렬 방식에 따라 blogPosts 업데이트
            _updateBlogPosts();
            isLoading = false; // 데이터 로드 완료
          });
        } else {
          print('Failed to parse data: data or data[\'data\'] is null');
          setState(() {
            isLoading = false; // 실패해도 로딩 종료
          });
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        setState(() {
          isLoading = false; // 실패해도 로딩 종료
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false; // 에러 발생 시 로딩 종료
      });
    }
  }

  // 포스트 데이터를 파싱하는 함수
  List<diaryPost_model> parsePosts(List<dynamic> postDataList) {
    List<diaryPost_model> posts = [];
    for (var postData in postDataList) {
      diaryPost_model post = diaryPost_model(
        postid: postData['POST_ID'], // POST_ID 추가
        author: postData['USER_ID'] ?? 'Unknown', // 작성자의 이름 필드
        authorID: postData['USER_ID'],
        createdAt: DateTime.parse(postData['POST_CREATE']),
        title: postData['POST_NAME'],
        content: postData['POST_CONTENT'] ?? '',
        likes: postData['POST_LIKE'],
        liked: postData['liked'] ?? false, // 서버에서 받은 liked 상태 반영
        subjList: [
          (postData['혼캎'] ?? 0) == 1,
          (postData['혼영'] ?? 0) == 1,
          (postData['혼놀'] ?? 0) == 1,
          (postData['혼밥'] ?? 0) == 1,
          (postData['혼박'] ?? 0) == 1,
          (postData['혼술'] ?? 0) == 1,
          (postData['기타'] ?? 0) == 1,
        ],
        images: postData['images'] != null
            ? List<String>.from(postData['images'])
            : [],
      );
      posts.add(post);
    }
    return posts;
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
      print('Blog posts updated. Current count: ${blogPosts.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String userId = userProvider.user?.userId ?? 'unknown';
    String userCharacter = userProvider.user?.userCharacter ?? 'unknown';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF6EDFF), // Start color
              Colors.white, // End color
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: const Color(0xFFF0E8FA),
              toolbarHeight: SizeScaler.scaleSize(context, 32),

              automaticallyImplyLeading: false, // Remove default back arrow
              title: Row(
                children: [
                  // Left area: Custom back icon
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
                  // Center area: Text (centered)
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        '나홀로일지',
                        style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 8.8),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // Right area: Search icon and user profile
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Search icon
                        IconButton(
                          icon: Icon(Icons.search,
                              size: SizeScaler.scaleSize(context, 14)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DiarySearch()),
                            );
                          },
                        ),
                        // User profile picture
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiaryUser(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: SizeScaler.scaleSize(context, 7.25),
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person,
                                color: Colors.white,
                                size: SizeScaler.scaleSize(context, 12.325)),
                          ),
                        ),
                        SizedBox(
                            width: SizeScaler.scaleSize(context, 2)), // Spacing
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFFBABABA), // Gray divider color
              height: SizeScaler.scaleSize(context, 0.5), // Divider thickness
            ),
            if (visible)
              SizedBox(
                height: SizeScaler.scaleSize(context, 25), // Spacing
                child: Padding(
                  padding:
                      EdgeInsets.only(right: SizeScaler.scaleSize(context, 2)),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.black,
                          size: SizeScaler.scaleSize(context, 9)), // Close icon
                      onPressed: () {
                        setState(() {
                          visible =
                              false; // Hide the container when X is pressed
                        });
                      },
                    ),
                  ),
                ),
              ),
            if (visible)
              Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: SizeScaler.scaleSize(
                              context, 12)), // Left padding
                      child: Text(
                        "오늘의 나홀로 생활은 어땠어?",
                        style: TextStyle(
                            fontSize: SizeScaler.scaleSize(context, 12),
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: SizeScaler.scaleSize(
                              context, 12)), // Left padding
                      child: Text(
                        "나홀로일지로 당신의 하루를 기록해 보세요.",
                        style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 7),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF727272), // Text color
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (visible)
              Container(
                margin: EdgeInsets.only(
                    top: SizeScaler.scaleSize(context, 12)), // Spacing
                width: SizeScaler.scaleSize(context, 160),
                height: SizeScaler.scaleSize(context, 86),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFC974F9),
                      Color(0xFF9A9EF0)
                    ], // Gradient colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(
                      SizeScaler.scaleSize(context, 10)), // Rounded corners
                ),
                child: Row(
                  children: [
                    // Left area
                    Expanded(
                      flex: 89,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: SizeScaler.scaleSize(context, 11),
                                top: SizeScaler.scaleSize(
                                    context, 18)), // Padding
                            child: Text(
                              '일지 쓰고\n캐릭터 성장시키자!',
                              style: TextStyle(
                                  fontSize: SizeScaler.scaleSize(context, 10),
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(
                              height:
                                  SizeScaler.scaleSize(context, 14)), // Spacing
                          Padding(
                              padding: EdgeInsets.only(
                                  left: SizeScaler.scaleSize(context,
                                      11)), // Same left padding as above
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DiaryWriting()),
                                  );
                                },
                                child: Text(
                                  '오늘 하루 기록하러 가기 >',
                                  style: TextStyle(
                                      fontSize:
                                          SizeScaler.scaleSize(context, 6),
                                      color: Colors.white),
                                ),
                              )),
                        ],
                      ),
                    ),
                    // Right area
                    Expanded(
                      flex: 68,
                      child: OverflowBox(
                        maxHeight: SizeScaler.scaleSize(context, 100),
                        child: Stack(
                          children: [
                            Positioned(
                              right: SizeScaler.scaleSize(context, 0),
                              bottom:
                                  SizeScaler.scaleSize(context, 0), // Overflow
                              child: Image.asset(
                                "assets/images/$userCharacter.png",
                                scale: 4.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (visible)
              SizedBox(height: SizeScaler.scaleSize(context, 30)), // Spacing
            if (visible)
              Container(
                color: const Color(0xFFDCD6E3).withOpacity(0.9), // 구분선
                height: SizeScaler.scaleSize(context, 3), // 구분선 두께
              ),
            // Sorting buttons
            Container(
              padding: EdgeInsets.only(
                  left: SizeScaler.scaleSize(context, 11),
                  top: SizeScaler.scaleSize(context, 7),
                  bottom: SizeScaler.scaleSize(context, 7)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(_buttonLabels.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index; // Update selected button index
                        _updateBlogPosts(); // Update blogPosts based on selection
                      });
                    },
                    child: Container(
                      width:
                          SizeScaler.scaleSize(context, 30.5), // 버튼의 가로 길이 설정
                      height: SizeScaler.scaleSize(context, 13), // 버튼의 세로 길이 설정
                      margin: EdgeInsets.only(
                          right: SizeScaler.scaleSize(context, 2.5)),
                      padding: EdgeInsets.symmetric(
                          vertical: SizeScaler.scaleSize(context, 2),
                          horizontal: SizeScaler.scaleSize(context, 4)),
                      decoration: BoxDecoration(
                        color: _selectedIndex == index
                            ? const Color(0xFFD8CBFF)
                            : Colors.white, // 선택된
                        border: Border.all(
                            color: _selectedIndex == index
                                ? const Color(0xFF794FFF)
                                : const Color(0xFF9C9C9C), // 테두리 색상
                            width: SizeScaler.scaleSize(context, 0.25)),
                        borderRadius: BorderRadius.circular(
                            SizeScaler.scaleSize(
                                context, 7)), // Rounded corners
                      ),
                      child: Center(
                        child: Text(
                          _buttonLabels[index],
                          style: TextStyle(
                            fontSize: SizeScaler.scaleSize(context, 5.5),
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
            // Post list or loading indicator
            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(), // Show loading indicator
                    )
                  : blogPosts.isEmpty
                      ? Center(
                          child: Text(
                            '게시물이 없습니다.',
                            style: TextStyle(
                              fontSize: SizeScaler.scaleSize(context, 10),
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.separated(
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
                                top: index == 0
                                    ? 0
                                    : SizeScaler.scaleSize(context, 18),
                                bottom: SizeScaler.scaleSize(context, 18),
                                right: SizeScaler.scaleSize(context, 9),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Profile picture, author, time
                                        GestureDetector(
                                          onTap: () {
                                            // Navigate to user profile
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DiaryUser(),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: SizeScaler.scaleSize(
                                                    context, 10),
                                                backgroundColor: Colors.grey,
                                                child: Icon(Icons.person,
                                                    color: Colors.white,
                                                    size: SizeScaler.scaleSize(
                                                        context,
                                                        17)), // Default icon
                                              ),
                                              SizedBox(
                                                  width: SizeScaler.scaleSize(
                                                      context, 5)), // Spacing
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(post.author,
                                                        style: TextStyle(
                                                            fontSize: SizeScaler
                                                                .scaleSize(
                                                                    context, 8),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                    Text(
                                                        _formatDateTime(
                                                            post.createdAt),
                                                        style: TextStyle(
                                                            fontSize: SizeScaler
                                                                .scaleSize(
                                                                    context, 6),
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: const Color(
                                                                0xFF7E7E7E))),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            height: SizeScaler.scaleSize(
                                                context, 6)), // Spacing
                                        // Title, content preview
                                        GestureDetector(
                                          onTap: () {
                                            // Navigate to post detail page
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DiaryText(
                                                  postid:
                                                      post.postid, // POST_ID 추가
                                                  postTitle: post.title,
                                                  postContent: post.content,
                                                  author: post.author,
                                                  authorID: post.authorID,
                                                  createdAt: post.createdAt,
                                                  subjList: post.subjList,
                                                  images: post.images,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(post.title,
                                                  style: TextStyle(
                                                      fontSize:
                                                          SizeScaler.scaleSize(
                                                              context, 8))),
                                              SizedBox(
                                                  height: SizeScaler.scaleSize(
                                                      context, 4.5)), // Spacing
                                              Text(post.getContentPreview(38),
                                                  style: TextStyle(
                                                      fontSize:
                                                          SizeScaler.scaleSize(
                                                              context, 6),
                                                      fontWeight:
                                                          FontWeight.w200,
                                                      color: const Color(
                                                          0xFF7E7E7E))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width: SizeScaler.scaleSize(context, 8)),
                                  // Right column (image)
                                  post.images.isNotEmpty
                                      ? Container(
                                          width:
                                              SizeScaler.scaleSize(context, 70),
                                          height:
                                              SizeScaler.scaleSize(context, 70),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .grey[300], // Placeholder color
                                            borderRadius: BorderRadius.circular(
                                                SizeScaler.scaleSize(
                                                    context, 4)),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                SizeScaler.scaleSize(
                                                    context, 4)),
                                            child: Image.memory(
                                              base64Decode(post
                                                  .images[0]), // 첫 번째 이미지 디코딩
                                              fit: BoxFit
                                                  .cover, // 이미지가 컨테이너를 꽉 채우도록 설정
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.red,
                                                    size: SizeScaler.scaleSize(
                                                        context, 20),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width:
                                              SizeScaler.scaleSize(context, 70),
                                          height:
                                              SizeScaler.scaleSize(context, 70),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .grey[300], // Placeholder color
                                            borderRadius: BorderRadius.circular(
                                                SizeScaler.scaleSize(
                                                    context, 4)),
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
      ),
      floatingActionButton: Container(
        width: SizeScaler.scaleSize(context, 59),
        height: SizeScaler.scaleSize(context, 21),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA526FF), Color(0xFF5D5FF4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius:
              BorderRadius.circular(SizeScaler.scaleSize(context, 20)),
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to writing page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DiaryWriting()),
            ).then((_) {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              String userId = userProvider.user!.userId;
              // 페이지를 다녀온 후 데이터를 항상 다시 불러옴
              fetchData(userId);
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0, // 눌렀을 때의 elevation 제거
          focusElevation: 0, // 포커스 시 elevation 제거
          hoverElevation: 0, // 마우스 hover 시 elevation 제거
          splashColor: Colors.transparent, // 눌렀을 때 물결 효과 제거
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: SizeScaler.scaleSize(context, 4)),
              Text('글쓰기',
                  style: TextStyle(
                      fontSize: SizeScaler.scaleSize(context, 8),
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              SizedBox(width: SizeScaler.scaleSize(context, 4)),
              const Icon(Icons.edit, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // Date formatting function
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 1) {
      // More than 24 hours ago
      return DateFormat('yyyy.MM.dd').format(dateTime);
    } else if (difference.inHours >= 1) {
      // More than 1 hour ago
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes >= 1) {
      // More than 1 minute ago
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
