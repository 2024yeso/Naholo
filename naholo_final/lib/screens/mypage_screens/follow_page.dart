// lib/screens/followers_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nahollo/sizeScaler.dart'; // SystemUiOverlayStyle 사용을 위한 임포트

class FollowPage extends StatefulWidget {
  final int selectedIndex;

  const FollowPage({super.key, required this.selectedIndex});

  @override
  _FollowPageState createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 탭 컨트롤러 초기화 및 초기 선택 탭 설정
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.selectedIndex);
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
          tabs: const [
            Tab(text: '${56} 팔로워'),
            Tab(text: '${88} 팔로잉'),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          // 팔로워 목록
          ListView.builder(
            itemCount: 10,
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
            itemCount: 10,
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
