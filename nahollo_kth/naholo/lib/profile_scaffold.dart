// lib/screens/profile_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle 사용을 위한 임포트
import '../sizescaler.dart'; // SizeScaler 임포트
import 'followers_page.dart';
import 'following_page.dart';
import 'profile_edit_page.dart';
import 'wishlist_page.dart';

// 추가된 임포트
import 'package:http/http.dart' as http; // HTTP 요청을 위한 패키지
import 'dart:convert'; // JSON 디코딩을 위해 필요
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Maps
import 'package:permission_handler/permission_handler.dart'; // 권한 요청
import 'dart:async'; // 비동기 처리에 필요
import '../review.dart'; // 리뷰 모델 임포트
import '../user_profile.dart'; // 사용자 프로필 모델 임포트

class ProfileScaffold extends StatefulWidget {
  final String userId;

  ProfileScaffold({required this.userId});

  @override
  _ProfileScaffoldState createState() => _ProfileScaffoldState();
}

class _ProfileScaffoldState extends State<ProfileScaffold> {
  int _selectedTab = 0; // 일지와 지도 전환 상태 관리

  // 추가된 상태 변수
  List<Review> _reviews = []; // 서버로부터 가져온 리뷰 데이터를 저장할 리스트
  bool _isLoading = true; // 로딩 상태를 관리하기 위한 변수
  Completer<GoogleMapController> _mapController = Completer(); // GoogleMap 컨트롤러
  Set<Marker> _markers = {}; // 지도에 표시될 마커들
  UserProfile? _userProfile; // 사용자 프로필 정보

  // 초기 위치 설정 (서울)
  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.5665, 126.9780), // 서울 좌표
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _requestLocationPermission(); // 위치 권한 요청
    _fetchMyPageData(); // 마이페이지 데이터 가져오기
  }

  // 위치 권한 요청 함수
  void _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  // 서버로부터 마이페이지 데이터를 가져오는 함수
  void _fetchMyPageData() async {
    final userId = widget.userId;
    try {
      // 동시에 프로필 정보와 리뷰 데이터를 가져옵니다.
      final profileFuture = fetchUserProfile(userId);
      final reviewsFuture = fetchReviews(userId);

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
      print('Error fetching data: $e');
    }
  }

  // 사용자 프로필 정보를 가져오는 함수
  Future<UserProfile> fetchUserProfile(String userId) async {
    final url = Uri.parse('http://10.0.2.2:8000/get_user_profile/?user_id=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 서버로부터 받은 데이터 출력
        print('User profile data: $data');
        return UserProfile.fromJson(data);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  // 리뷰 데이터를 받아오는 함수
  Future<List<Review>> fetchReviews(String userId) async {
    final url = Uri.parse('http://10.0.2.2:8000/my_page/?user_id=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reviewsJson = data['reviews'] as List;
        // 서버로부터 받은 데이터 출력
        print('Received reviews: $reviewsJson');
        return reviewsJson.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  // 리뷰 데이터를 기반으로 지도에 마커 추가
  void _addMarkers() {
    setState(() {
      _markers.clear(); // 기존 마커 초기화
      _reviews.forEach((review) {
        // 실제 장소의 좌표를 사용하여 마커 추가
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

  // 이미지 URL을 그대로 사용
  String getFullImageUrl(String imageUrl) {
    return imageUrl; // 서버에서 받은 URL을 그대로 사용
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: SizeScaler.scaleSize(context, 18),
                          backgroundColor: Colors.purple,
                          backgroundImage: _userProfile != null && _userProfile!.imageUrl != null
                              ? NetworkImage(_userProfile!.imageUrl!)
                              : null,
                          child: _userProfile != null && _userProfile!.imageUrl != null
                              ? null
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
                                      '${_userProfile?.followerCount ?? 0}',
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
                                      '${_userProfile?.followingCount ?? 0}',
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
                    ),
                    // 가고 싶어요 버튼
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    // 탭 전환 버튼 (일지/지도)
                    Row(
                      children: [
                        // 일지 버튼
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTab = 0;
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
                                _selectedTab = 1;
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
                    SizedBox(height: SizeScaler.scaleSize(context, 8)),
                    // 일지/지도 내용 전환
                    _selectedTab == 0 ? _buildJournalContent(context) : _buildMapContent(context),
                  ],
                ),
              ),
            ),
    );
  }

  // 일지 내용 빌드
  Widget _buildJournalContent(BuildContext context) {
    if (_reviews.isEmpty) {
      return Center(
        child: Text(
          '리뷰가 없습니다.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: review.reviewImage != null && review.reviewImage!.isNotEmpty
                ? Image.network(
                    review.reviewImage!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported);
                    },
                  )
                : Icon(Icons.image_not_supported),
            title: Text(review.whereName),
            subtitle: Text(review.reviewContent),
            trailing: Text('${review.whereRate}/5'),
          ),
        );
      },
    );
  }

  // 지도 내용 빌드
  Widget _buildMapContent(BuildContext context) {
    return Container(
      height: SizeScaler.scaleSize(context, 300),
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
