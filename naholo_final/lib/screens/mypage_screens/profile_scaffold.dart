// screens/profile_scaffold.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/models/user_profile.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/mypage_screens/follow_page.dart';
import 'package:nahollo/screens/mypage_screens/profile_edit_page.dart';
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

        setState(() {
          // Null 체크를 통해 안전하게 데이터를 처리
          _userProfile = data['user_info'] != null
              ? UserProfile.fromJson(data['user_info'])
              : null;

          print(_userProfile);
          // _reviews에 데이터가 없을 때 빈 리스트 할당
          _reviews = data['reviews'] != null
              ? List<Map<String, dynamic>>.from(data['reviews'])
              : [];

          print(data['user_info']);
          print(data["reviews"]);
          _isLoading = false;
          _addMarkers(where["where"]); // 필요에 따라 수정
        });
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
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
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
                            reviews: _reviews, userProfile: _userProfile)
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
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileEditPage(),
              )),
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
                : Icon(Icons.person,
                    size: SizeScaler.scaleSize(context, 18),
                    color: Colors.white),
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
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FollowPage(selectedIndex: 0),
                    )),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditPage(),
                  ),
                );
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
              // 버튼 클릭 시 동작
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
