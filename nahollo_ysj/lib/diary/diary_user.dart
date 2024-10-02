import 'package:flutter/material.dart';
import 'package:flutter_application_1/diary/diary_text.dart';
import 'package:flutter_application_1/sizeScaler.dart'; // 크기 조절
import '../models/diaryPost_model.dart'; // 포스트 모델
import 'package:flutter_application_1/models/user_model.dart'; // UserModel 가져오기
import 'package:intl/intl.dart'; // 날짜 포맷

final UserModel user = UserModel(
  userId: "user123",
  userPw: "password",
  name: "홍길동",
  phone: "010-1234-5678",
  birth: "1990-01-01",
  gender: "남",
  nickName: "얼뚱이",
  userCharacter: "오징어",
  lv: 10,
  introduceDiary: "얼뚱이의 일지",
  image: "",
);

final String clientID = "유저";
final String authorID = "유저";
int follower = 30;

class DiaryUser extends StatefulWidget {
  @override
  _DiaryUserState createState() => _DiaryUserState();
}

class _DiaryUserState extends State<DiaryUser> {
  int _selectedIndex = 0;

  List<diaryPost_model> allBlogPosts = [
    diaryPost_model(
      author: '유저',
      authorID: '유저',
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
      title: '드디어 레고 조립을 완료하였습니다.',
      content: '저의 취미인 레고 조립.. 그동안 시간이 없어서 많이 못했었는데요! 약 반년 걸린 긴 활동을 마무리했습니다.',
      likes: 10,
      liked: false,
      subjList: [true, false, true, false, true, true, false],
    ),
    diaryPost_model(
      author: '유저',
      authorID: '유저',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      title: '사건의지평선',
      content:
          '생각이 많은 건 말이야\n당연히 해야 할 일이야\n나에겐 우리가 지금 1순위야\n안전한 유리병을 핑계로\n바람을 가둬 둔 것 같지만\n\n기억나? 그날의 우리가\n잡았던 그 손엔 말이야\n설레임보다 커다란 믿음이 담겨서\n난 함박웃음을 지었지만\n울음이 날 것도 같았어\n소중한 건 언제나 두려움이니까\n\n문을 열면 들리던 목소리\n너로 인해 변해있던 따뜻한 공기\n여전히 자신 없지만 안녕히\n\n저기, 사라진 별의 자리\n아스라이 하얀 빛\n한동안은 꺼내 볼 수 있을 거야\n아낌없이 반짝인 시간은\n조금씩 옅어져 가더라도\n너와 내 맘에 살아 숨 쉴테니\n\n여긴, 서로의 끝이 아닌\n새로운 길 모퉁이\n익숙함에 진심을 속이지 말자\n하나 둘 추억이 떠오르면\n많이 많이 그리워할 거야\n고마웠어요 그래도 이제는\n사건의 지평선 너머로\n\n솔직히 두렵기도 하지만\n노력은 우리에게 정답이 아니라서\n마지막 선물은 산뜻한 안녕\n\n저기, 사라진 별의 자리\n아스라이 하얀 빛\n한동안은 꺼내 볼 수 있을 거야\n아낌없이 반짝인 시간은\n조금씩 옅어져 가더라도\n너와 내맘에 살아 숨 쉴 테니\n\n여긴, 서로의 끝이 아닌\n새로운 길 모퉁이\n익숙함에 진심을 속이지 말자\n하나 둘 추억이 떠오르면\n많이 많이 그리워할 거야\n고마웠어요 그래도 이제는\n사건의 지평선 너머로\n\n저기 사라진 별의 자리 아스라이 하얀 빛\n한동안은 꺼내 볼 수 있을 거야\n아낌없이 반짝인 시간은\n조금씩 옅어져 가더라도\n너와 내 맘에 살아 숨 쉴 테니\n\n여긴, 서로의 끝이 아닌\n새로운 길 모퉁이\n익숙함에 진심을 속이지 말자\n하나 둘 추억이 떠오르면\n많이 많이 그리워할 거야\n고마웠어요 그래도 이제는\n사건의 지평선 너머로\n\n사건의 지평선 너머로',
      likes: 9,
      liked: true,
      subjList: [true, true, true, true, true, true, true],
    ),
    diaryPost_model(
      author: '유저',
      authorID: '유저',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      title: 'Banana',
      content:
          'Bananananananananananananananana\nBanananananananananananananananana\nBananananananananananananananananana',
      likes: 10,
      liked: true,
      subjList: [true, false, true, false, true, true, false],
    ),
    diaryPost_model(
      author: '유저',
      authorID: '유저',
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

  String _sortLabel = '최신순';

  @override
  void initState() {
    super.initState();
    blogPosts = List.from(allBlogPosts);
    _sortByLatest(); // 기본값을 인기순으로 정렬
  }

  void _sortByLikes() {
    blogPosts.sort((a, b) => b.likes.compareTo(a.likes));
  }

  void _sortByLatest() {
    blogPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
              child: Text(
                  clientID == authorID ? '나의 일지' : '${user.nickName} 님의 일지',
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
            color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
            height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          // 위쪽 영역 (배경 사진)
                          Container(
                            height: SizeScaler.scaleSize(context, 75),
                            color: Colors.grey,
                          ),
                          // 아래쪽 영역
                          Container(
                            height: SizeScaler.scaleSize(context, 85),
                            color: Colors.white,
                            child: Center(
                                child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // 중앙 정렬 추가
                              children: [
                                SizedBox(
                                  height: SizeScaler.scaleSize(context, 4),
                                ),
                                Text(
                                  user.nickName,
                                  style: TextStyle(
                                      fontSize:
                                          SizeScaler.scaleSize(context, 11),
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Lv. ${user.lv}',
                                  style: TextStyle(
                                      fontSize:
                                          SizeScaler.scaleSize(context, 7),
                                      fontWeight: FontWeight.w300,
                                      color: const Color(0xFF7E7E7E)),
                                ),
                                SizedBox(
                                  height: SizeScaler.scaleSize(context, 5),
                                ),
                                Text(
                                  user.introduceDiary,
                                  style: TextStyle(
                                      fontSize:
                                          SizeScaler.scaleSize(context, 8.5),
                                      fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                    height: SizeScaler.scaleSize(context, 3)),
                                Text(
                                  '팔로워 $follower명',
                                  style: TextStyle(
                                      fontSize:
                                          SizeScaler.scaleSize(context, 5),
                                      fontWeight: FontWeight.w300,
                                      color: const Color(0xFF7E7E7E)),
                                ),
                              ],
                            )),
                          ),
                        ],
                      ),
                      // 두 영역 사이에 겹치는 이미지
                      Positioned(
                        top: 30, // top 값을 조정
                        child: Icon(
                          Icons.person,
                          size: SizeScaler.scaleSize(context, 70),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.settings),
                          iconSize: SizeScaler.scaleSize(context, 10),
                          onPressed: () {
                            // 설정 모드 On
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
                    height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: SizeScaler.scaleSize(context, 13),
                        top: SizeScaler.scaleSize(context, 7),
                        bottom: SizeScaler.scaleSize(context, 7)),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: Text('최신순'),
                                      onTap: () {
                                        setState(() {
                                          _sortLabel = '최신순';
                                          _sortByLatest();
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      title: Text('인기순'),
                                      onTap: () {
                                        setState(() {
                                          _sortLabel = '인기순';
                                          _sortByLikes();
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                _sortLabel,
                                style: TextStyle(
                                  fontSize: SizeScaler.scaleSize(context, 8),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                size: SizeScaler.scaleSize(context, 15),
                                color: const Color(0xFF797979),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // 내부 리스트뷰 스크롤 비활성화
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
                          top: index == 0
                              ? 0
                              : SizeScaler.scaleSize(context, 18),
                          bottom: SizeScaler.scaleSize(context, 18),
                          right: SizeScaler.scaleSize(context, 9),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬
                          children: [
                            // 작성 시간 표시
                            Text(
                              _formatDateTime(post.createdAt),
                              style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 6),
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF7E7E7E),
                              ),
                            ),
                            SizedBox(
                                height: SizeScaler.scaleSize(context, 6)), // 간격
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
                                  Container(
                                    // 이미지 임시 대체
                                    width: SizeScaler.scaleSize(
                                        context, 160), // 사진의 가로 길이
                                    height: SizeScaler.scaleSize(
                                        context, 160), // 사진의 세로 길이
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300], // 회색 상자
                                      borderRadius: BorderRadius.circular(
                                          SizeScaler.scaleSize(
                                              context, 10)), // 둥근 모서리
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          SizeScaler.scaleSize(context, 10)),
                                  Text(
                                    post.title,
                                    style: TextStyle(
                                        fontSize:
                                            SizeScaler.scaleSize(context, 8),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                      height: SizeScaler.scaleSize(
                                          context, 3)), // 간격

                                  // 좋아요, 댓글 정보 Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // 좋아요 아이콘 및 좋아요 수
                                      SizedBox(
                                          width: SizeScaler.scaleSize(
                                              context, 1)), // 간격
                                      Icon(
                                        Icons.thumb_up_alt_outlined,
                                        size: SizeScaler.scaleSize(context, 8),
                                        color: const Color(0xFF7E7E7E),
                                      ),
                                      SizedBox(
                                          width: SizeScaler.scaleSize(
                                              context, 2)), // 간격
                                      Text(
                                        '${post.likes}',
                                        style: TextStyle(
                                            fontSize: SizeScaler.scaleSize(
                                                context, 6),
                                            color: const Color(0xFF7E7E7E)),
                                      ),
                                      SizedBox(
                                          width: SizeScaler.scaleSize(
                                              context, 5)), // 아이콘 간 간격
                                      // 댓글 아이콘 및 댓글 수
                                      Icon(Icons.comment_outlined,
                                          size:
                                              SizeScaler.scaleSize(context, 8),
                                          color: const Color(0xFF7E7E7E)),
                                      SizedBox(
                                          width: SizeScaler.scaleSize(
                                              context, 2)), // 간격
                                      Text(
                                        '4', // 실제 댓글 수를 모델에 추가해서 표시 가능
                                        style: TextStyle(
                                            fontSize: SizeScaler.scaleSize(
                                                context, 6),
                                            color: const Color(0xFF7E7E7E)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat(' yyyy.MM.dd HH.mm').format(dateTime);
  }
}
