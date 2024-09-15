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

  // 샘플 데이터
  List<DiaryPostList> allBlogPosts = [
    DiaryPostList(
      author: '시금치',
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
      title: '드디어 레고 조립을 완료하였습니다.',
      content: '저의 취미인 레고 조립.. 그동안 시간이 없어서 많이 못했었는데요! 약 반년 걸린 긴 활동을 마무리했습니다.',
      hot: 10,
      subscribe: false,
    ),
    DiaryPostList(
      author: '윤하',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      title: '사건의지평선',
      content: '생각이 많은 건 말이야\n당연히 해야 할 일이야\n나에겐 우리가 지금 1순위야\n안전한 유리병을 핑계로\n바람을 가둬 둔 것 같지만\n\n기억나? 그날의 우리가\n잡았던 그 손엔 말이야\n설레임보다 커다란 믿음이 담겨서\n난 함박웃음을 지었지만\n울음이 날 것도 같았어\n소중한 건 언제나 두려움이니까\n\n문을 열면 들리던 목소리\n너로 인해 변해있던 따뜻한 공기\n여전히 자신 없지만 안녕히\n\n저기, 사라진 별의 자리\n아스라이 하얀 빛\n한동안은 꺼내 볼 수 있을 거야\n아낌없이 반짝인 시간은\n조금씩 옅어져 가더라도\n너와 내 맘에 살아 숨 쉴테니\n\n여긴, 서로의 끝이 아닌\n새로운 길 모퉁이\n익숙함에 진심을 속이지 말자\n하나 둘 추억이 떠오르면\n많이 많이 그리워할 거야\n고마웠어요 그래도 이제는\n사건의 지평선 너머로\n\n솔직히 두렵기도 하지만\n노력은 우리에게 정답이 아니라서\n마지막 선물은 산뜻한 안녕\n\n저기, 사라진 별의 자리\n아스라이 하얀 빛\n한동안은 꺼내 볼 수 있을 거야\n아낌없이 반짝인 시간은\n조금씩 옅어져 가더라도\n너와 내맘에 살아 숨 쉴 테니\n\n여긴, 서로의 끝이 아닌\n새로운 길 모퉁이\n익숙함에 진심을 속이지 말자\n하나 둘 추억이 떠오르면\n많이 많이 그리워할 거야\n고마웠어요 그래도 이제는\n사건의 지평선 너머로\n\n저기 사라진 별의 자리 아스라이 하얀 빛\n한동안은 꺼내 볼 수 있을 거야\n아낌없이 반짝인 시간은\n조금씩 옅어져 가더라도\n너와 내 맘에 살아 숨 쉴 테니\n\n여긴, 서로의 끝이 아닌\n새로운 길 모퉁이\n익숙함에 진심을 속이지 말자\n하나 둘 추억이 떠오르면\n많이 많이 그리워할 거야\n고마웠어요 그래도 이제는\n사건의 지평선 너머로\n\n사건의 지평선 너머로',
      hot: 9,
      subscribe: true,
    ),
    DiaryPostList(
      author: '샐러드',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      title: '자취생 꿀팁 모음',
      content: '안녕하세요! 오늘은 여러분들을 위해 혼놀 꿀팁을 가져와봤습니다! 요즘 같은 어쩌구 저쩌구',
      hot: 10,
      subscribe: true,
    ),
  ];

  // 화면에 보여질 포스트 리스트
  List<DiaryPostList> blogPosts = [];

  // 버튼 라벨
  final List<String> _buttonLabels = ['인기순', '최신순', '구독'];

  @override
  void initState() {
    super.initState();
    blogPosts = List.from(allBlogPosts); // 기본 설정인 인기순에 맞춰 모든 포스트를 보여주기 위해 blogPosts에 모든 원본 데이터 복사
    blogPosts.sort((a, b) => b.hot.compareTo(a.hot)); // 인기순 정렬
  } // 만약 설정으로 기본 정렬을 고를 수 있게 할 경우 이곳을 수정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: SizeScaler.scaleSize(context, 25, 50), 
            title: Center(
              child: Text('나홀로일지',
                  style: TextStyle(
                    fontSize: SizeScaler.scaleSize(context, 8, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
            ),
            actions: [
              Row(
                children: [
                  // 검색 페이지로 이동하는 버튼
                  IconButton(
                    icon: Icon(Icons.search, size: SizeScaler.scaleSize(context, 14, 28)),
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
                          builder: (context) => DiaryUser(
                              author: '유저이름'), // '유저이름'은 실제 유저 이름으로 변경해야 함
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: SizeScaler.scaleSize(context, 7.25, 14.5),
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white, size: SizeScaler.scaleSize(context, 15, 30)),
                    ),
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
                      if (_selectedIndex == 0) {
                        // 인기순: 'hot' 값으로 내림차순 정렬
                        blogPosts = List.from(allBlogPosts);
                        blogPosts.sort((a, b) => b.hot.compareTo(a.hot));
                      } else if (_selectedIndex == 1) {
                        // 최신순: 'createdAt' 값으로 내림차순 정렬
                        blogPosts = List.from(allBlogPosts);
                        blogPosts
                            .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      } else if (_selectedIndex == 2) {
                        blogPosts = allBlogPosts
                            .where((post) => post.subscribe)
                            .toList();
                        blogPosts.sort((a, b) => b.createdAt
                            .compareTo(a.createdAt)); // 구독한 포스트들을 최신순으로 정렬
                      }
                    });
                  },
                  child: Container(
                    width: SizeScaler.scaleSize(context, 29, 58), // 버튼의 가로 길이 설정
                    height: SizeScaler.scaleSize(context, 12, 24), // 버튼의 세로 길이 설정
                    margin: EdgeInsets.only(
                        right:
                            SizeScaler.scaleSize(context, 2, 4)), // 버튼 사이 간격 설정
                    padding: EdgeInsets.symmetric(
                        vertical: SizeScaler.scaleSize(context, 2, 4),
                        horizontal:
                            SizeScaler.scaleSize(context, 4, 8)), // 버튼 내부 패딩
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? const Color(0xFFE7E7E7)
                          : Colors.white, // 선택된 버튼 색상 : 선택되지 않은 버튼 색상
                      border:
                          Border.all(color: const Color(0xFF9C9C9C)), // 테두리 색상
                      borderRadius: BorderRadius.circular(
                          SizeScaler.scaleSize(context, 12, 24)), // 모서리 둥글게
                    ),
                    child: Center(
                      child: Text(
                        _buttonLabels[index],
                        style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 5, 10), // 버튼 텍스트 폰트 크기 설정
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
                thickness: SizeScaler.scaleSize(context, 3, 6), // 글 구분선 두께
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
                                    builder: (context) => DiaryUser(
                                        author: post.author), // DiaryUser로 이동
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: SizeScaler.scaleSize(context, 10, 20),
                                    backgroundColor: Colors.grey, // 회색 프로필 사진
                                    child: Icon(Icons.person, color: Colors.white, size: SizeScaler.scaleSize(context, 20, 40)), // 기본 아이콘
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(post.author,
                                            style: TextStyle(
                                                fontSize: SizeScaler.scaleSize(context, 8, 16),
                                                fontWeight: FontWeight.w600)),
                                        Text(_formatDateTime(post.createdAt),
                                            style: TextStyle(
                                                fontSize: SizeScaler.scaleSize(context, 6, 12),
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    const Color(0xFF7E7E7E))),
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
                                          fontSize: SizeScaler.scaleSize(context, 8, 16))),
                                  SizedBox(height: 12.0),
                                  Text(post.getContentPreview(50),
                                      style: TextStyle(
                                          fontSize: SizeScaler.scaleSize(context, 6, 12),
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
                        width: SizeScaler.scaleSize(context, 62, 124), // 사진의 가로 길이
                        height:
                            SizeScaler.scaleSize(context, 64, 128), // 사진의 세로 길이
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // 회색 상자
                          borderRadius: BorderRadius.circular(
                              SizeScaler.scaleSize(context, 4, 8)), // 둥근 모서리
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