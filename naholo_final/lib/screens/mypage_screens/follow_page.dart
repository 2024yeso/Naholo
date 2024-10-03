import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:provider/provider.dart';
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
  List<dynamic> followers = [];
  List<dynamic> following = [];
  Map<String, bool> followingStates = {}; // 팔로잉 상태를 관리하는 Map

  // 서버에서 팔로워와 팔로잉 정보를 가져옴
  Future<void> fetchFollowPage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId ?? '';

    final url = Uri.parse('${Api.baseUrl}/follow_page/?user_id=$userId');

    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          followers = data['followers'] ?? [];
          following = data['following'] ?? [];

          // 팔로우 상태 초기화
          for (var user in following) {
            followingStates[user['USER_ID']] = true; // 팔로우 상태로 설정
          }
          for (var user in followers) {
            if (!followingStates.containsKey(user['USER_ID'])) {
              followingStates[user['USER_ID']] = false; // 팔로우되지 않은 상태로 설정
            }
          }
        });
      } else {
        throw Exception('Failed to load follow page data');
      }
    } catch (e) {
      print('Error fetching follow page data: $e');
    }
  }

  // 팔로우/언팔로우 토글 함수
  Future<void> toggleFollow(String userId, String followerId) async {
    final url = Uri.parse('${Api.baseUrl}/toggle_follow/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'follower_id': followerId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (data['status'] == 'unfollowed') {
            followingStates[followerId] = false;
            // 팔로잉에서 삭제된 경우 리스트에서도 제거
            following.removeWhere((user) => user['USER_ID'] == followerId);
          } else if (data['status'] == 'followed') {
            followingStates[followerId] = true;
            // 팔로잉 목록에 새롭게 추가된 경우 리스트에 추가
            if (followers.any((user) => user['USER_ID'] == followerId)) {
              following.add(followers
                  .firstWhere((user) => user['USER_ID'] == followerId));
            }
          }
        });
      } else {
        throw Exception('Failed to toggle follow');
      }
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }

  // Base64 문자열이 맞는지 확인하는 함수
  bool isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 팔로워 페이지의 유저 아이템 빌드 (팔로우 버튼 있음)
  Widget _buildFollowerTile(Map<String, dynamic> user) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.user?.userId ?? '';

    // NICKNAME과 INTRODUCE를 UTF-8 디코딩 처리
    String nickname = user['NICKNAME'] != null
        ? utf8.decode(user['NICKNAME'].toString().codeUnits)
        : '이름 없음';
    String introduce = user['INTRODUCE'] != null
        ? utf8.decode(user['INTRODUCE'].toString().codeUnits)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.withOpacity(0.5),
          backgroundImage: user['IMAGE'] != null && isBase64(user['IMAGE'])
              ? MemoryImage(base64Decode(user['IMAGE']))
              : const AssetImage('assets/images/default_image.png')
                  as ImageProvider,
        ),
        title: Text(
          nickname, // 디코딩된 닉네임 출력
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: SizeScaler.scaleSize(context, 10)),
        ),
        subtitle: Text(
          introduce, // 디코딩된 소개문 출력
          style: TextStyle(fontSize: SizeScaler.scaleSize(context, 8)),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(
              SizeScaler.scaleSize(context, 35),
              SizeScaler.scaleSize(context, 19),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: followingStates[user['USER_ID']] ?? false
                ? const Color(0xffb075ff)
                : const Color(0xffa971f4),
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
          ),
          onPressed: () => toggleFollow(currentUserId, user['USER_ID']),
          child: Text(
            followingStates[user['USER_ID']] ?? false ? '언팔로우' : '팔로우',
            style: TextStyle(
                fontSize: SizeScaler.scaleSize(context, 8),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

// 팔로잉 페이지의 유저 아이템 빌드 (삭제 버튼 있음)
  Widget _buildFollowingTile(Map<String, dynamic> user) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.user?.userId ?? '';

    // NICKNAME과 INTRODUCE를 UTF-8 디코딩 처리
    String nickname = user['NICKNAME'] != null
        ? utf8.decode(user['NICKNAME'].toString().codeUnits)
        : '이름 없음';
    String introduce = user['INTRODUCE'] != null
        ? utf8.decode(user['INTRODUCE'].toString().codeUnits)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.withOpacity(0.5),
          backgroundImage: user['IMAGE'] != null && isBase64(user['IMAGE'])
              ? MemoryImage(base64Decode(user['IMAGE']))
              : const AssetImage('assets/images/default_image.png')
                  as ImageProvider,
        ),
        title: Text(
          nickname, // 디코딩된 닉네임 출력
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: SizeScaler.scaleSize(context, 10)),
        ),
        subtitle: Text(
          introduce, // 디코딩된 소개문 출력
          style: TextStyle(fontSize: SizeScaler.scaleSize(context, 8)),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(
              SizeScaler.scaleSize(context, 35),
              SizeScaler.scaleSize(context, 19),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: const Color(0xffcccdf8),
            foregroundColor: Colors.black,
            padding: EdgeInsets.zero,
          ),
          onPressed: () => toggleFollow(currentUserId, user['USER_ID']),
          child: Text(
            '삭제',
            style: TextStyle(
                fontSize: SizeScaler.scaleSize(context, 9),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.selectedIndex);
    fetchFollowPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: TabBar(
          dividerColor: Colors.grey,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          controller: _tabController,
          tabs: [
            Tab(text: '${followers.length} 팔로워'),
            Tab(text: '${following.length} 팔로잉'),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          // 팔로워 목록 (팔로우/언팔로우 버튼)
          ListView.builder(
            itemCount: followers.length,
            itemBuilder: (context, index) {
              return _buildFollowerTile(followers[index]);
            },
          ),
          // 팔로잉 목록 (삭제 버튼)
          ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              return _buildFollowingTile(following[index]);
            },
          ),
        ],
      ),
    );
  }
}
