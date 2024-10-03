// screens/profile_scaffold.dart

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/models/user_profile.dart';
import 'package:nahollo/providers/user_profile_provider.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/mypage_screens/follow_page.dart';
import 'package:nahollo/screens/mypage_screens/profile_edit_page.dart';
import 'package:nahollo/screens/mypage_screens/save_page.dart';
import 'package:nahollo/services/network_service.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_where_data.dart';
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
  final List<String> _reviewImages = [];
  bool _isLoading = true;
  Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  UserProfile? _userProfile;

  void resetMapController() {
    if (_mapController.isCompleted) {
      _mapController = Completer<GoogleMapController>();
    }
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchMyPageData();
  }

  void _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  Future<void> _fetchMyPageData() async {
    print("데이터 가져오기 시작");
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId ?? '';

    try {
      print("사용자 ID: $userId");
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/my_page/?user_id=$userId'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        // UserProfile의 데이터를 비동기적으로 가져옴
        UserProfile? userProfile = data['user_info'] != null
            ? UserProfile.fromJson(data['user_info']) // await 사용
            : null;

        setState(() {
          _userProfile = userProfile; // 이제 _userProfile에 비동기적으로 할당
          _reviews = data['reviews'] != null
              ? List<Map<String, dynamic>>.from(data['reviews'])
              : [];
          _isLoading = false;
        });
        _addMarkers();
        // UserProfileProvider를 사용하여 _userProfile을 설정
        final userProfileProvider =
            Provider.of<UserProfileProvider>(context, listen: false);
        if (_userProfile != null) {
          print("굿");
          userProfileProvider.setUserProfile(_userProfile!);
        }
      } else {
        print('서버 응답 에러: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('데이터 가져오기 에러: $e');
    }
  }

  // 마커 추가 메서드 정의
  void _addMarkers() {
    setState(
      () {
        _markers.clear(); // 기존 마커를 제거
        for (var review in _reviews) {
          // 리뷰에서 위도와 경도 정보를 가져옵니다.
          double latitude = review["LATITUDE"];
          double longitude = review["LONGITUDE"];

          // Marker 객체를 생성하여 _markers에 추가합니다.
          _markers.add(
            Marker(
              markerId:
                  MarkerId(review["REVIEW_ID"].toString()), // 고유한 마커 ID 설정
              position: LatLng(latitude, longitude), // 위치 정보 (위도, 경도)
              infoWindow: InfoWindow(
                title: review["WHERE_NAME"], // 마커의 제목 (장소 이름)
                snippet: review["REVIEW_CONTENT"], // 마커의 부가 설명 (리뷰 내용)
              ),
            ),
          );
        }
        print("마커 목록: $_markers");
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
          preferredSize: const Size.fromHeight(1.0), // 높이를 1.0으로 설정
          child: Container(
            color: Colors.grey,
            height: 1.0, // 컨테이너의 높이도 1.0으로 설정
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        ? JournalContent(
                            reviews: _reviews,
                            userProfile: _userProfile,
                            reviewImages: _reviewImages,
                          )
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
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileEditPage(
                  image: _userProfile?.image,
                ),
              ),
            );

            // 반환된 값을 확인
            print("수정 후 반환된 값: $result");

            // result가 true일 경우 데이터를 다시 로드
            if (result == true) {
              print("프로필 수정 후 데이터 다시 로드 실행됨");
              _fetchMyPageData(); // 프로필 데이터를 다시 불러오기
            } else {
              print("프로필 수정 결과를 받지 못함. 반환 값: $result");
            }
          },
          child: CircleAvatar(
            radius: SizeScaler.scaleSize(context, 15),
            backgroundColor: Colors.grey.withOpacity(0.5),
            child: _userProfile != null && _userProfile!.image != null
                ? ClipOval(
                    child: Image.memory(
                      _userProfile!.image!,
                      width: SizeScaler.scaleSize(context, 32),
                      height: SizeScaler.scaleSize(context, 32),
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipOval(
                    child: Image.asset(
                      'assets/images/default_image.png', // 기본 이미지 경로 사용
                      width: SizeScaler.scaleSize(context, 32),
                      height: SizeScaler.scaleSize(context, 32),
                      fit: BoxFit.cover,
                    ),
                  ),
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
    // 서버에서 팔로워, 팔로잉 수를 받아왔다면 해당 값으로 대체하세요.
    final follower = _userProfile?.follower_count;
    final following = _userProfile?.following_count;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: SizeScaler.scaleSize(context, 16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const FollowPage(selectedIndex: 0),
                      ));
                },
                child: Text(
                  '팔로워 $follower',
                  style: TextStyle(
                    fontSize: SizeScaler.scaleSize(context, 7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: SizeScaler.scaleSize(context, 16)),
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
            width: SizeScaler.scaleSize(context, 48),
            height: SizeScaler.scaleSize(context, 15),
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditPage(
                      image: _userProfile?.image,
                    ),
                  ),
                );

                // 반환된 값을 확인
                print("수정 후 반환된 값: $result");

                // result가 true일 경우 데이터를 다시 로드
                if (result == true) {
                  print("프로필 수정 후 데이터 다시 로드 실행됨");
                  _fetchMyPageData(); // 프로필 데이터를 다시 불러오기
                } else {
                  print("프로필 수정 결과를 받지 못함. 반환 값: $result");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF794FFF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeScaler.scaleSize(context, 4)),
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
          width: SizeScaler.scaleSize(context, 168),
          height: SizeScaler.scaleSize(context, 23),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavePage(),
                  ));
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: const Color(0xFFEFBDFF).withOpacity(0.1),
              side: const BorderSide(color: Color(0xFF7320BC), width: 0.5),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag_outlined,
                    size: SizeScaler.scaleSize(context, 12)),
                SizedBox(width: SizeScaler.scaleSize(context, 4)),
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
              resetMapController();
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
