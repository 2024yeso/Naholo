// lib/screens/followers_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/providers/user_profile_provider.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:provider/provider.dart'; // SystemUiOverlayStyle 사용을 위한 임포트
import 'dart:convert';
import 'package:http/http.dart' as http;

class FollowPage extends StatefulWidget {
  final int selectedIndex;

  const FollowPage({super.key, required this.selectedIndex});

  @override
  _FollowPageState createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Future<Map<String, dynamic>> fetchFollowPage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId ?? '';

    final url = Uri.parse('${Api.baseUrl}/follow_page/?user_id=$userId');

    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        // JSON 데이터를 Map으로 변환
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);
        return data;
      } else {
        throw Exception('Failed to load follow page data');
      }
    } catch (e) {
      print('Error fetching follow page data: $e');
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    // 탭 컨트롤러 초기화 및 초기 선택 탭 설정
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.selectedIndex);
    fetchFollowPage();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final userprofile = userProfileProvider.userProfile;
    int folloer = userprofile!.follower_count;
    int following = userprofile.following_count;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: TabBar(
          dividerColor: Colors.grey,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          controller: _tabController,
          tabs: [
            Tab(text: '$folloer 팔로워'),
            Tab(text: '$following 팔로잉'),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          // 팔로워 목록
          ListView.builder(
            itemCount: folloer,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.withOpacity(0.5),
                    child: Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  title: Text(
                    '이름 ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeScaler.scaleSize(context, 10)),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        SizeScaler.scaleSize(context, 35),
                        SizeScaler.scaleSize(context, 19),
                      ), // 최소 크기 설정 (너비, 높이)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xffcccdf8),
                      foregroundColor: const Color(0xff181427),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {},
                    child: Text(
                      '삭제',
                      style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 9),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
          // 팔로잉 목록
          ListView.builder(
            itemCount: following,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.withOpacity(0.5),
                    child: Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  title: Text(
                    '이름 ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeScaler.scaleSize(context, 10)),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        SizeScaler.scaleSize(context, 40),
                        SizeScaler.scaleSize(context, 19),
                      ), // 최소 크기 설정 (너비, 높이)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xffa971f4),
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {},
                    child: Text(
                      '팔로잉',
                      style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 9),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
