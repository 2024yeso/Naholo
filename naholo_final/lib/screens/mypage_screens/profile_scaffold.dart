// screens/profile_scaffold.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/models/review.dart';
import 'package:nahollo/models/user_model.dart';
import 'package:nahollo/models/user_profile.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/mypage_screens/follow_page.dart';

import 'package:nahollo/screens/mypage_screens/profile_edit_page.dart';
import 'package:nahollo/services/network_service.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_where_data.dart';
import 'package:nahollo/test_where_review_data.dart';
import 'package:nahollo/util.dart';
import 'package:nahollo/widgets/journal_content.dart';
import 'package:nahollo/widgets/map_content.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProfileScaffold extends StatefulWidget {
  const ProfileScaffold({super.key});

  @override
  _ProfileScaffoldState createState() => _ProfileScaffoldState();
}

class _ProfileScaffoldState extends State<ProfileScaffold> {
  int _selectedTab = 0;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  UserProfile? _userProfile;
  bool isLoading = true;

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
    image: "sfsdf",
  );

  int follower = 10, following = 30;

  /* Future<void> fetchData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      String userId = user?.userId ?? '';

      // 리뷰 정보 가져오기 (user_id를 쿼리 파라미터로 전달)
      final reviewResponse = await http.get(
        Uri.parse("${Api.baseUrl}/where/${widget.whereId}/reviews?user_id=$userId"),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8'
        },
      );

    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }  */

  // USER_ID와 일치하는 리뷰를 필터링하여 가져오는 함수
  void _fetchReviews() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var user = userProvider.user;

    _reviews = whereReview["where_review"]
        .where((review) => review["USER_ID"] == user!.userId)
        .toList();
  }

  void resetMapController() {
    // 새로운 Completer로 초기화
    if (_mapController.isCompleted) {
      _mapController = Completer<GoogleMapController>();
    }
  }

  @override
  void initState() {
    super.initState();
    // UserProvider를 통해 현재 로그인된 유저 정보를 가져옵니다.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // _fetchReviews();
    _requestLocationPermission();
    _fetchMyPageData();
  }

  // 위치 권한 요청 메서드 정의
  void _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  // 마이페이지 데이터 가져오기 메서드 정의
  Future<void> _fetchMyPageData() async {
    print("되냐?");
    final userId = _userProfile?.userId ?? '';
    try {
      final profileFuture = NetworkService.fetchUserProfile(userId);
      final reviewsFuture = NetworkService.fetchReviews(userId);
      print(userId);
      final results = await Future.wait([profileFuture, reviewsFuture]);

      setState(() {
        _userProfile = results[0] as UserProfile;
        _reviews = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
        _addMarkers(where["where"]);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('데이터 가져오기 에러: $e');
    }
  }

  // 마커 추가 메서드 정의
  void _addMarkers(List<Map<String, dynamic>> wheres) {
    setState(
      () {
        _markers.clear();
        for (var review in _reviews) {
          for (var where in wheres) {
            if (where["WHERE_ID"] == review["WHERE_ID"]) {
              double latitude = where["LATITUDE"];
              double longitude = where["LONGITUDE"];
              _markers.add(
                Marker(
                  markerId: MarkerId(review["WHERE_NAME"]),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(
                    title: review["WHERE_NAME"],
                    snippet: review["REVIEW_CONTENT"],
                  ),
                ),
              );
            }
          }
        }
        print("이거 마커임 ㅋㅋ $_markers");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavBar(
        selectedIndex: 4,
      ),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // 선의 두께 설정
          child: Container(
            color: Colors.grey, // 선의 색상 설정
            height: 1.0, // 선의 두께
          ),
        ),
        title: Text(
          '마이페이지',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: SizeScaler.scaleSize(
              context,
              SizeScaler.scaleSize(context, 5),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      backgroundColor: Colors.white,
      body: /* _isLoading
          ? const Center(child: CircularProgressIndicator())  
          : */
          SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(SizeScaler.scaleSize(context, 10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: SizeScaler.scaleSize(context, 6),
              ),
              // 프로필 섹션
              _buildProfileSection(),
              SizedBox(
                height: SizeScaler.scaleSize(context, 12),
              ),

              // 팔로워, 팔로잉, 프로필 수정 버튼
              _buildProfileActions(context),
              // 가고 싶어요 버튼
              _buildWishlistButton(context),
              const Divider(),
              // 탭 전환 버튼 (일지/지도)
              Row(
                children: [
                  _buildTabButton(Icons.apps, '일지', 0),
                  _buildTabButton(Icons.map_outlined, '지도', 1),
                ],
              ),
              SizedBox(height: SizeScaler.scaleSize(context, 8)),
              _selectedTab == 0
                  ? JournalContent(reviews: _reviews, userProfile: _userProfile)
                  : MapContent(
                      markers: _markers,
                      mapController: _mapController,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // 프로필 섹션 빌드 메서드
  Widget _buildProfileSection() {
    return Row(
      children: [
        SizedBox(
          width: SizeScaler.scaleSize(context, 6),
        ),
        CircleAvatar(
          radius: SizeScaler.scaleSize(context, 15),
          backgroundColor: Colors.grey.withOpacity(0.5),
          child: _userProfile != null && _userProfile!.image != null
              ? ClipOval(
                  child: Image.memory(
                    _userProfile!.image!, // Uint8List 이미지를 표시
                    width: SizeScaler.scaleSize(context, 32),
                    height: SizeScaler.scaleSize(context, 32),
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: SizeScaler.scaleSize(context, 18),
                  color: Colors.white,
                ),
        ),
        SizedBox(width: SizeScaler.scaleSize(context, 8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이름과 레벨을 수평으로 배치
              Row(
                children: [
                  Text(
                    _userProfile?.nickname ?? '닉네임 없음',
                    style: TextStyle(
                      fontSize: SizeScaler.scaleSize(context, 9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: SizeScaler.scaleSize(context, 5)),
                  Text(
                    'Lv. ${_userProfile?.level ?? 0}',
                    style: TextStyle(
                      fontSize: SizeScaler.scaleSize(context, 6),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeScaler.scaleSize(context, 0)),
              Text(
                _userProfile?.introduce ?? '자기소개가 없습니다.',
                style: TextStyle(
                  fontSize: SizeScaler.scaleSize(context, 5),
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 팔로워, 팔로잉, 프로필 수정 버튼 빌드 메서드
  Widget _buildProfileActions(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: SizeScaler.scaleSize(context, 16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const FollowPage(selectedIndex: 0), // 팔로워 탭 선택(),
                    )),
                child: Text(
                  '팔로워 $follower',
                  style: TextStyle(
                    fontSize: SizeScaler.scaleSize(context, 7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: SizeScaler.scaleSize(context, 16)), // 간격
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FollowPage(selectedIndex: 1),
                  ),
                ),
                child: Text(
                  '팔로잉 $following',
                  style: TextStyle(
                    fontSize: SizeScaler.scaleSize(context, 7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: SizeScaler.scaleSize(context, 48), // 버튼 너비
            height: SizeScaler.scaleSize(context, 15), // 버튼 높이
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditPage(),
                  ),
                ); // 프로필 수정 버튼 클릭 시 동작
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF794FFF), // 버튼 색상
                elevation: 0, // 그림자 제거
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      SizeScaler.scaleSize(context, 4)), // 모서리 둥글게
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                '프로필 수정',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeScaler.scaleSize(context, 7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 가고 싶어요 버튼 빌드 메서드
  Widget _buildWishlistButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 5,
        ),
        child: SizedBox(
          width: SizeScaler.scaleSize(context, 168), // 버튼 너비
          height: SizeScaler.scaleSize(context, 23), // 버튼 높이
          child: ElevatedButton(
            onPressed: () {
              // 버튼 클릭 시 동작
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),

              backgroundColor:
                  const Color(0xFFEFBDFF).withOpacity(0.1), // 버튼 색상
              side:
                  const BorderSide(color: Color(0xFF7320BC), width: 0.5), // 수정
              elevation: 0,
              padding: EdgeInsets.zero, // 패딩 제거
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, // 텍스트 및 아이콘 중앙 정렬
              children: [
                Icon(Icons.flag_outlined,
                    size: SizeScaler.scaleSize(context, 12)),
                SizedBox(width: SizeScaler.scaleSize(context, 4)), // 간격
                Text(
                  '가고 싶어요',
                  style: TextStyle(
                    fontSize: SizeScaler.scaleSize(context, 7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 탭 전환 버튼 빌드 메서드
  Widget _buildTabButton(IconData icon, String label, int tabIndex) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = tabIndex;
            if (_selectedTab == 1) {
              resetMapController(); // 지도 탭을 눌렀을 때 지도 컨트롤러 초기화
            }
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: SizeScaler.scaleSize(context, 4)),
            Icon(
              icon,
              size: SizeScaler.scaleSize(context, 12),
              color: _selectedTab == tabIndex
                  ? const Color.fromARGB(255, 0, 0, 0)
                  : Colors.grey,
            ),
            SizedBox(height: SizeScaler.scaleSize(context, 4)),
            Container(
              height: 2,
              color: _selectedTab == tabIndex
                  ? const Color.fromARGB(255, 0, 0, 0)
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
