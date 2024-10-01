// diary_search.dart
import 'package:flutter/material.dart';
import 'diary_text.dart'; // 나홀로일지 글 상세보기
import 'diary_user.dart'; // 유저 프로필
import '../models/diaryPost_model.dart'; // 포스트 모델
import 'package:intl/intl.dart'; // 날짜 포맷
import 'package:flutter_application_1/sizeScaler.dart'; // 크기 조절

class DiarySearch extends StatefulWidget {
  @override
  _DiarySearchState createState() => _DiarySearchState();
}

class _DiarySearchState extends State<DiarySearch> {
  int _selectedIndex = 0;

  // 샘플 데이터
  List<diaryPost_model> allBlogPosts = [
    diaryPost_model(
      author: '시금치',
      authorID: '1',
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
      title: '드디어 레고 조립을 완료하였습니다.',
      content: '저의 취미인 레고 조립.. 그동안 시간이 없어서 많이 못했었는데요! 약 반년 걸린 긴 활동을 마무리했습니다.',
      likes: 10,
      liked: false,
      subjList: [true, false, true, false, true, true, false],
    ),
    diaryPost_model(
      author: '윤하',
      authorID: '2',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      title: '사건의지평선',
      content:
          '생각이 많은 건 말이야\n당연히 해야 할 일이야\n나에겐 우리가 지금 1순위야\n안전한 유리병을 핑계로\n바람을 가둬 둔 것 같지만\n\n기억나? 그날의 우리가\n잡았던 그 손엔 말이야\n설레임보다 커다란 믿음이 담겨서\n난 함박웃음을 지었지만\n울음이 날 것도 같았어\n소중한 건 언제나 두려움이니까\n\n문을 열면 들리던 목소리\n너로 인해 변해있던 따뜻한 공기\n여전히 자신 없지만 안녕히\n\n저기, 사라진 별의 자리\n아스라이 하얀 빛\n한동안은 꺼내 볼 수 있을 거야\n아낌없이 반짝인 시간은\n조금씩 옅어져 가더라도\n너와 내 맘에 살아 숨 쉴테니\n\n여긴, 서로의 끝이 아닌\n새로운 길 모퉁이\n익숙함에 진심을 속이지 말자\n하나 둘 추억이 떠오르면\n많이 많이 그리워할 거야\n고마웠어요 그래도 이제는\n사건의 지평선 너머로\n\n솔직히 두렵기도 하지만\n노력은 우리에게 정답이 아니라서\n마지막 선물은 산뜻한 안녕\n\n저기, 사라진 별의 자리\n아스라이 하얀 빛\n한동안은 꺼내 볼 수 있을 거야\n아낌없이 반짝인 시간은\n조금씩 옅어져 가더라도\n너와 내맘에 살아 숨 쉴 테니\n\n여긴, 서로의 끝이 아닌\n새로운 길 모퉁이\n익숙함에 진심을 속이지 말자\n하나 둘 추억이 떠오르면\n많이 많이 그리워할 거야\n고마웠어요 그래도 이제는\n사건의 지평선 너머로\n\n저기 사라진 별의 자리 아스라이 하얀 빛\n한동안은 꺼내 볼 수 있을 거야\n아낌없이 반짝인 시간은\n조금씩 옅어져 가더라도\n너와 내 맘에 살아 숨 쉴 테니\n\n여긴, 서로의 끝이 아닌\n새로운 길 모퉁이\n익숙함에 진심을 속이지 말자\n하나 둘 추억이 떠오르면\n많이 많이 그리워할 거야\n고마웠어요 그래도 이제는\n사건의 지평선 너머로\n\n사건의 지평선 너머로',
      likes: 9,
      liked: true,
      subjList: [true, true, true, true, true, true, true],
    ),
    diaryPost_model(
      author: '바나나',
      authorID: '3',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      title: 'Banana',
      content:
          'Bananananananananananananananana\nBanananananananananananananananana\nBananananananananananananananananana',
      likes: 10,
      liked: true,
      subjList: [true, false, true, false, true, true, false],
    ),
    diaryPost_model(
      author: '경희대학교',
      authorID: '4',
      createdAt: DateTime.now().subtract(Duration(days: 23)),
      title: '대학영어 면제 기준 완화 안내',
      content:
          '후마니타스칼리지와의 총 3차례 면담을 통해 대학영어 면제 기준 완화를 요청하였습니다.\n이후 면제 기준에 대해 국제캠퍼스 후마니타스칼리지와 서울캠퍼스 후마니타스칼리지의 합의가 완료된 상황입니다. 추후 해당 안건에 대해 본부의 심의가 진행될 예정이며, 심의 진행 완료 후 면제 기준 변경 안건이 확정됩니다.\n\n면제 기준 완화(안)\n\n가. 기존 이수면제 기준 완화\nTOEIC 915점 -> 875점\n\n나. 적용 시기\n2025학년도 1학기',
      likes: 100,
      liked: true,
      subjList: [false, false, false, false, false, false, true],
    ),
  ];

  // 화면에 보여질 포스트 리스트
  List<diaryPost_model> blogPosts = [];

  // 버튼 라벨
  final List<String> _buttonLabels = ['인기순', '최신순', '팔로우'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              toolbarHeight: SizeScaler.scaleSize(context, 25),
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
                        '나홀로일지 검색',
                        style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 8),
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
            Container(
              color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
              height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
            ),
            Padding(
              padding: EdgeInsets.only(
                top: SizeScaler.scaleSize(context, 15),
                // bottom: SizeScaler.scaleSize(context, 15),
                left: SizeScaler.scaleSize(context, 12),
                right: SizeScaler.scaleSize(context, 12),
              ),
              child: Container(
                width: SizeScaler.scaleSize(context, 169),
                height: SizeScaler.scaleSize(context, 28),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius:
                      BorderRadius.circular(SizeScaler.scaleSize(context, 14)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: SizeScaler.scaleSize(context, 8),
                    ),
                    Icon(Icons.search, size: SizeScaler.scaleSize(context, 14)),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: SizeScaler.scaleSize(context, 5)),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // 검색 버튼을 눌렀을 때의 동작 추가
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.transparent),
                        minimumSize: WidgetStateProperty.all(Size(
                            SizeScaler.scaleSize(context, 30),
                            SizeScaler.scaleSize(context, 20))),
                      ),
                      child: Text(
                        '검색',
                        style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 7),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF7C7C7C),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 8), //수
            ),
            Container(
              padding: EdgeInsets.only(
                  left: SizeScaler.scaleSize(context, 14),
                  top: SizeScaler.scaleSize(context, 7),
                  bottom: SizeScaler.scaleSize(context, 7)),
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
                          blogPosts.sort((a, b) => b.likes.compareTo(a.likes));
                        } else if (_selectedIndex == 1) {
                          // 최신순: 'createdAt' 값으로 내림차순 정렬
                          blogPosts = List.from(allBlogPosts);
                          blogPosts.sort(
                              (a, b) => b.createdAt.compareTo(a.createdAt));
                        } else if (_selectedIndex == 2) {
                          blogPosts =
                              allBlogPosts.where((post) => post.liked).toList();
                          blogPosts.sort((a, b) => b.createdAt
                              .compareTo(a.createdAt)); // 구독한 포스트들을 최신순으로 정렬
                        }
                      });
                    },
                    child: Container(
                      width: SizeScaler.scaleSize(context, 30.5), // 버튼의 가로 길이 설정
                      height: SizeScaler.scaleSize(context, 13), // 버튼의 세로 길이 설정
                      margin: EdgeInsets.only(
                          right:
                              SizeScaler.scaleSize(context, 2.5)), // 버튼 사이 간격 설정
                      padding: EdgeInsets.symmetric(
                          vertical: SizeScaler.scaleSize(context, 2),
                          horizontal:
                              SizeScaler.scaleSize(context, 4)), // 버튼 내부 패딩
                      decoration: BoxDecoration(
                        color: _selectedIndex == index
                            ? const Color(0xFFD8CBFF)
                            : Colors.white, // 선택된 버튼 색상 : 선택되지 않은 버튼 색상
                        border: Border.all(
                            color: _selectedIndex == index
                                ? const Color(0xFF794FFF)
                                : const Color(0xFF9C9C9C), // 테두리 색상
                            width: SizeScaler.scaleSize(context, 0.25)),
                        borderRadius: BorderRadius.circular(
                            SizeScaler.scaleSize(context, 7)), // 모서리 둥글게
                      ),
                      child: Center(
                        child: Text(
                          _buttonLabels[index],
                          style: TextStyle(
                            fontSize: SizeScaler.scaleSize(
                                context, 5.5), // 버튼 텍스트 폰트 크기 설정
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
            // ...
            Expanded(
              child: ListView.separated(
                itemCount: blogPosts.length,
                separatorBuilder: (context, index) => Divider(
                  color: const Color(0xFFD9D9D9), // 구분선
                  thickness: SizeScaler.scaleSize(context, 3), // 글 구분선 두께
                ),
                itemBuilder: (context, index) {
                  final post = blogPosts[index];
                  return Container(
                    padding: EdgeInsets.only(
                      left: SizeScaler.scaleSize(context, 13),
                      top: index == 0 ? 0 : SizeScaler.scaleSize(context, 18),
                      bottom: SizeScaler.scaleSize(context, 18),
                      right: SizeScaler.scaleSize(context, 9),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬
                      children: [
                        // 왼쪽 칸
                        // 왼쪽 칸
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween, // 추가
                            children: [
                              // 프로필 사진, 작성자, 시간
                              GestureDetector(
                                onTap: () {
                                  // 유저 프로필 페이지로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DiaryUser(
                                          authorID:
                                              post.authorID), // DiaryUser로 이동
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: SizeScaler.scaleSize(context, 10),
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.person,
                                          color: Colors.white,
                                          size: SizeScaler.scaleSize(
                                              context, 17)), // 기본 아이콘
                                    ),
                                    SizedBox(
                                        width: SizeScaler.scaleSize(
                                            context, 5)), // 간격
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(post.author,
                                              style: TextStyle(
                                                  fontSize:
                                                      SizeScaler.scaleSize(
                                                          context, 8),
                                                  fontWeight: FontWeight.w600)),
                                          Text(_formatDateTime(post.createdAt),
                                              style: TextStyle(
                                                  fontSize:
                                                      SizeScaler.scaleSize(
                                                          context, 6),
                                                  fontWeight: FontWeight.w300,
                                                  color:
                                                      const Color(0xFF7E7E7E))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height:
                                      SizeScaler.scaleSize(context, 6)), // 간격
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
                                    Text(post.title,
                                        style: TextStyle(
                                            fontSize: SizeScaler.scaleSize(
                                                context, 8))),
                                    SizedBox(
                                        height: SizeScaler.scaleSize(
                                            context, 4.5)), // 간격
                                    Text(post.getContentPreview(38),
                                        style: TextStyle(
                                            fontSize: SizeScaler.scaleSize(
                                                context, 6),
                                            fontWeight: FontWeight.w200,
                                            color: const Color(0xFF7E7E7E))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: SizeScaler.scaleSize(context, 8)), // 간격
                        // 오른쪽 칸 (사진)
                        Container(
                          width: SizeScaler.scaleSize(context, 70), // 사진의 가로 길이
                          height:
                              SizeScaler.scaleSize(context, 70), // 사진의 세로 길이
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // 회색 상자
                            borderRadius: BorderRadius.circular(
                                SizeScaler.scaleSize(context, 4)), // 둥근 모서리
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
