// screens/profile_scaffold.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';
import '../widgets/sizescaler.dart';
import '../widgets/journal_content.dart';
import '../widgets/map_content.dart';
import '../services/network_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import '../models/review.dart';
import 'package:flutter/services.dart';
import 'followers_page.dart';
import 'following_page.dart';
import 'profile_edit_page.dart';
import 'wishlist_page.dart';

class ProfileScaffold extends StatefulWidget {
  @override
  _ProfileScaffoldState createState() => _ProfileScaffoldState();
}

class _ProfileScaffoldState extends State<ProfileScaffold> {
  int _selectedTab = 0;
  List<Review> _reviews = [];
  bool _isLoading = true;
  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  UserProfile? _userProfile;

  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    // UserProvider를 통해 현재 로그인된 유저 정보를 가져옵니다.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _userProfile = userProvider.user;

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
    final userId = _userProfile?.userId ?? '';
    try {
      final profileFuture = NetworkService.fetchUserProfile(userId);
      final reviewsFuture = NetworkService.fetchReviews(userId);
      print(userId);
      final results = await Future.wait([profileFuture, reviewsFuture]);

      setState(() {
        _userProfile = results[0] as UserProfile;
        _reviews = results[1] as List<Review>;
        _isLoading = false;
        _addMarkers();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('데이터 가져오기 에러: $e');
    }
  }

  // 마커 추가 메서드 정의
  void _addMarkers() {
    setState(() {
      _markers.clear();
      _reviews.forEach((review) {
        if (review.latitude != null && review.longitude != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(review.whereName),
              position: LatLng(review.latitude!, review.longitude!),
              infoWindow: InfoWindow(
                title: review.whereName,
                snippet: review.reviewContent,
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeScaler.scaleSize(context, 12),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(SizeScaler.scaleSize(context, 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 섹션
                    _buildProfileSection(),
                    Divider(),
                    // 팔로워, 팔로잉, 프로필 수정 버튼
                    _buildProfileActions(context),
                    // 가고 싶어요 버튼
                    _buildWishlistButton(context),
                    Divider(),
                    // 탭 전환 버튼 (일지/지도)
                    Row(
                      children: [
                        _buildTabButton(Icons.apps, '일지', 0),
                        _buildTabButton(Icons.map, '지도', 1),
                      ],
                    ),
                    SizedBox(height: SizeScaler.scaleSize(context, 8)),
                    _selectedTab == 0
                        ? JournalContent(reviews: _reviews, userProfile: _userProfile)
                        : MapContent(
                            markers: _markers,
                            initialPosition: _initialPosition,
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
        CircleAvatar(
          radius: SizeScaler.scaleSize(context, 18),
          backgroundColor: Colors.purple,
          child: _userProfile != null && _userProfile!.image != null
              ? ClipOval(
                  child: Image.memory(
                    _userProfile!.image!, // Uint8List 이미지를 표시
                    width: SizeScaler.scaleSize(context, 36),
                    height: SizeScaler.scaleSize(context, 36),
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
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
                    _userProfile?.nickname ?? '닉네임 없음',
                    style: TextStyle(
                      fontSize: SizeScaler.scaleSize(context, 10),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: SizeScaler.scaleSize(context, 8)),
                  Text(
                    'Lv. ${_userProfile?.level ?? 0}',
                    style: TextStyle(
                      fontSize: SizeScaler.scaleSize(context, 10),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeScaler.scaleSize(context, 1)),
              Text(
                _userProfile?.introduce ?? '자기소개가 없습니다.',
                style: TextStyle(
                  fontSize: SizeScaler.scaleSize(context, 7),
                  color: Colors.grey,
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
                      '${0}',
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
                      '${0}',
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
          // 우측에 프로필 수정 버튼
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
                borderRadius: BorderRadius.circular(8),
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
            borderRadius: BorderRadius.circular(8),
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
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: SizeScaler.scaleSize(context, 4)),
            Icon(
              icon,
              size: SizeScaler.scaleSize(context, 18),
              color: _selectedTab == tabIndex ? Colors.purple : Colors.grey,
            ),
            SizedBox(height: SizeScaler.scaleSize(context, 4)),
            Container(
              height: 2,
              color: _selectedTab == tabIndex ? Colors.purple : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
