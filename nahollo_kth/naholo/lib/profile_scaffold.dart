// lib/screens/profile_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle 사용을 위한 임포트
import '../sizescaler.dart'; // SizeScaler 임포트
import 'followers_page.dart';
import 'following_page.dart';
import 'profile_edit_page.dart';
import 'wishlist_page.dart';

class ProfileScaffold extends StatefulWidget {
  @override
  _ProfileScaffoldState createState() => _ProfileScaffoldState();
}

class _ProfileScaffoldState extends State<ProfileScaffold> {
  int _selectedTab = 0; // 일지와 지도 전환 상태 관리

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeScaler.scaleSize(context, 12), // 가독성을 위해 12로 설정
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(SizeScaler.scaleSize(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 섹션
              Row(
                children: [
                  CircleAvatar(
                    radius: SizeScaler.scaleSize(context, 18), // 적절한 크기로 설정
                    backgroundColor: Colors.purple,
                    child: Icon(
                      Icons.person,
                      size: SizeScaler.scaleSize(context, 18),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: SizeScaler.scaleSize(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 이름과 레벨을 수평으로 배치
                        Row(
                          children: [
                            Text(
                              '얼뚜이',
                              style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 10),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: SizeScaler.scaleSize(context, 8)), // 이름과 레벨 간격
                            Text(
                              'Lv. 55',
                              style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 10),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: SizeScaler.scaleSize(context, 1)),
                        Text(
                          '다양한 모험과 경험을 쌓아가는 시골 모험꾼 수수께끼의 마법사와 함께 돌아다니는 그녀 나름',
                          style: TextStyle(
                            fontSize: SizeScaler.scaleSize(context, 7),
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeScaler.scaleSize(context, 8)),
              Divider(),
              // 팔로워, 팔로잉, 프로필 수정 버튼
              Padding(
                padding: EdgeInsets.symmetric(vertical: SizeScaler.scaleSize(context, 8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 좌측에 팔로워와 팔로잉 버튼
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FollowersPage()),
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontSize: SizeScaler.scaleSize(context, 10),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '팔로워',
                                style: TextStyle(
                                  fontSize: SizeScaler.scaleSize(context, 10),
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: SizeScaler.scaleSize(context, 6)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FollowingPage()),
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontSize: SizeScaler.scaleSize(context, 10),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '팔로잉',
                                style: TextStyle(
                                  fontSize: SizeScaler.scaleSize(context, 10),
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // 우측에 프로필 수정 버튼 (모서리가 둥근 사각형으로 변경)
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileEditPage()),
                        );
                      },
                      child: Text(
                        '프로필 수정',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: SizeScaler.scaleSize(context, 10),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.purple),
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeScaler.scaleSize(context, 10),
                          vertical: SizeScaler.scaleSize(context, 4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 모서리가 둥근 사각형
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 가고 싶어요 버튼 (모서리가 둥근 사각형으로 변경)
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WishlistPage()),
                    );
                  },
                  child: Text(
                    '가고 싶어요',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: SizeScaler.scaleSize(context, 12),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeScaler.scaleSize(context, 60),
                      vertical: SizeScaler.scaleSize(context, 6),
                    ),
                    side: BorderSide(color: Colors.purple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 모서리가 둥근 사각형
                    ),
                  ),
                ),
              ),
              Divider(), // 가고 싶어요 버튼과 일지/지도 전환 버튼 사이에 Divider 추가

              // 탭 전환 버튼 (일지/지도) - 각 버튼을 행의 반에 배치하고 선택된 것을 표시하는 선 추가
              Row(
                children: [
                  // 일지 버튼
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTab = 0; // 일지 선택 시 상태 업데이트
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: SizeScaler.scaleSize(context, 4)),
                          Icon(
                            Icons.apps,
                            size: SizeScaler.scaleSize(context, 18),
                            color: _selectedTab == 0 ? Colors.purple : Colors.grey,
                          ),
                          SizedBox(height: SizeScaler.scaleSize(context, 4)),
                          // 선택된 경우 표시되는 얇은 선
                          Container(
                            height: 2,
                            color: _selectedTab == 0 ? Colors.purple : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 지도 버튼
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTab = 1; // 지도 선택 시 상태 업데이트
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: SizeScaler.scaleSize(context, 4)),
                          Icon(
                            Icons.map,
                            size: SizeScaler.scaleSize(context, 18),
                            color: _selectedTab == 1 ? Colors.purple : Colors.grey,
                          ),
                          SizedBox(height: SizeScaler.scaleSize(context, 4)),
                          Container(
                            height: 2,
                            color: _selectedTab == 1 ? Colors.purple : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Divider(), // 필요에 따라 Divider를 추가하거나 제거할 수 있습니다.
              SizedBox(height: SizeScaler.scaleSize(context, 8)),
              // 일지/지도 내용 전환
              _selectedTab == 0
                  ? _buildJournalContent(context)
                  : _buildMapContent(context),
            ],
          ),
        ),
      ),
    );
  }

  // 일지 내용 빌드
  Widget _buildJournalContent(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.apps, // 앱 아이콘 사용
          color: Colors.purple,
          size: SizeScaler.scaleSize(context, 80), // 아이콘 크기 증가
        ),
      ),
    );
  }

  // 지도 내용 빌드
  Widget _buildMapContent(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.map,
          color: Colors.purple,
          size: SizeScaler.scaleSize(context, 80), // 아이콘 크기 증가
        ),
      ),
    );
  }
}
