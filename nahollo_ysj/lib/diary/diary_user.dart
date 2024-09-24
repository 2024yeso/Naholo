import 'package:flutter/material.dart';
import 'package:flutter_application_1/sizeScaler.dart'; // 크기 조절
import 'package:flutter_application_1/models/user_model.dart'; // UserModel 가져오기

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
  introduce: "다이어트 실패하고 얼렁뚱땅 넘어간 사람 댓글에  누가 얼렁뚱땡이 이렇게 달아놨는데 그게 나임",
  image: 1,
);

int follower = 10, following = 30;

class DiaryUser extends StatelessWidget {
  final String authorID;

  DiaryUser({required this.authorID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: SizeScaler.scaleSize(context, 25),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.black, size: SizeScaler.scaleSize(context, 10)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            '마이페이지',
            style: TextStyle(
              fontSize: SizeScaler.scaleSize(context, 8),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          SizedBox(width: SizeScaler.scaleSize(context, 28))
        ], // 화면 중앙 맞추기 위한 여백 추가
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color(0xFFBABABA), // 타이틀 회색 구분선 색상
            height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 16)), // 간격

          // 유저 프로필
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeScaler.scaleSize(context, 16)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: SizeScaler.scaleSize(context, 16),
                  backgroundColor: Colors.grey,
                ),
                SizedBox(width: SizeScaler.scaleSize(context, 5)), // 간격
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 닉네임과 레벨 표시
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            user.nickName,
                            style: TextStyle(
                              fontSize: SizeScaler.scaleSize(context, 8),
                              fontWeight: FontWeight.w600,
                              color: Colors.black, // 닉네임 색상
                            ),
                          ),
                          SizedBox(
                              width:
                                  SizeScaler.scaleSize(context, 4)), // 간격 4픽셀
                          Text(
                            'Lv. ${user.lv}',
                            style: TextStyle(
                              fontSize: SizeScaler.scaleSize(context, 6),
                              fontWeight: FontWeight.w300,
                              color: Colors.black, // 레벨 색상
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeScaler.scaleSize(context, 4)),
                      // 자기소개 표시
                      Padding(
                        padding: EdgeInsets.only(
                            right:
                                SizeScaler.scaleSize(context, 22)), // 우측 여백 조정
                        child: Text(
                          user.introduce,
                          style: TextStyle(
                            fontSize: SizeScaler.scaleSize(context, 5),
                            fontWeight: FontWeight.w300,
                            color: Colors.black, // 자기소개 색상
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 30)),

          // 팔로워, 팔로잉, 프로필 수정 버튼
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeScaler.scaleSize(context, 16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '팔로워: $follower',
                      style: TextStyle(
                        fontSize: SizeScaler.scaleSize(context, 6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: SizeScaler.scaleSize(context, 16)), // 간격
                    Text(
                      '팔로잉: $following',
                      style: TextStyle(
                        fontSize: SizeScaler.scaleSize(context, 6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // 프로필 수정 버튼 클릭 시 동작
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 버튼 색상
                  ),
                  child: Text(
                    '프로필 수정',
                    style: TextStyle(
                      fontSize: SizeScaler.scaleSize(context, 6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 20)), // 아래 여백

          Center(
            child: SizedBox(
              width: SizeScaler.scaleSize(context, 168), // 버튼 너비
              height: SizeScaler.scaleSize(context, 23), // 버튼 높이
              child: ElevatedButton(
                onPressed: () {
                  // 버튼 클릭 시 동작
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFBDFF).withOpacity(0.1), // 버튼 색상
                  side: BorderSide(color: Colors.blue, width: 1), // 수정
                  elevation: 0,
                  padding: EdgeInsets.zero, // 패딩 제거
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // 텍스트 및 아이콘 중앙 정렬
                  children: [
                    Icon(Icons.flag, size: SizeScaler.scaleSize(context, 12)),
                    SizedBox(width: SizeScaler.scaleSize(context, 4)), // 간격
                    Text(
                      '가고 싶어요',
                      style: TextStyle(
                        fontSize: SizeScaler.scaleSize(context, 6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 11)), // 아래 여백

          // 구분선
          Container(
            color: const Color(0xFFBABABA), // 구분선 색상
            height: SizeScaler.scaleSize(context, 4), // 구분선 높이
          ),
        ],
      ),
    );
  }
}
