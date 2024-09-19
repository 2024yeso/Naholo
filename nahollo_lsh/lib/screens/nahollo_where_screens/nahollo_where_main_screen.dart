import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_register_screen.dart';
import 'package:nahollo/util.dart';
import 'package:http/http.dart' as http;

class NaholloWhereMainScreen extends StatefulWidget {
  const NaholloWhereMainScreen({super.key});

  @override
  State<NaholloWhereMainScreen> createState() => _NaholloWhereMainScreenState();
}

class _NaholloWhereMainScreenState extends State<NaholloWhereMainScreen> {
  final int _selectedIndex = 0; // 선택된 인덱스
  Map<String, dynamic> results = {}; // 데이터를 저장할 변수
  String _selectedType = "overall"; // 현재 선택된 타입 ("overall"이 기본값)

  Future<void> getNaholloWhereTopRated() async {
    try {
      var response =
          await http.get(Uri.parse("${Api.baseUrl}/where/top-rated"));
      if (response.statusCode == 200) {
        setState(() {
          results = jsonDecode(response.body)["data"];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getNaholloWhereTopRated(); // 화면 초기화 시 데이터 불러오기
  }

  @override
  Widget build(BuildContext context) {
    var size = SizeUtil.getScreenSize(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: size.width * 0.8,
                  height: size.width * 0.15,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) {
                      // Handle search query
                      print(value);
                    },
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 가로로 스크롤 가능하게 설정
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedType = "overall"; // 전체 보기
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(20, 10),
                        ),
                        child: const Text("전체"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedType = "play"; // 혼놀 보기
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(20, 10),
                        ),
                        child: const Text("혼놀"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedType = "eat"; // 혼밥 보기
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(20, 10),
                        ),
                        child: const Text("혼밥"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedType = "sleep"; // 혼박 보기
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(20, 10),
                        ),
                        child: const Text("혼박"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedType = "drink"; // 혼술 보기
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(20, 10),
                        ),
                        child: const Text("혼술"),
                      ),
                    ],
                  ),
                ),
                const Text("전국 핫플 혼놀 장소"),
                results.isEmpty
                    ? const CircularProgressIndicator() // 데이터를 불러오는 동안 로딩 표시
                    : SizedBox(
                        height: 300,
                        child: _selectedType == "overall"
                            ? buildOverallSection() // 전체 상위 8개 항목 빌드
                            : ListView(
                                shrinkWrap: true, // 크기 제약을 받을 수 있도록 설정
                                physics:
                                    const NeverScrollableScrollPhysics(), // 내부 스크롤 방지
                                children: buildTypeSection(_selectedType),
                              ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NaholloWhereRegisterScreen(),
                        ),
                      ),
                      child: const Text("글쓰기"),
                    ),
                  ],
                ),
                CustomBottomNavBar(selectedIndex: _selectedIndex)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 특정 타입별로 상위 항목을 보여주는 위젯 빌드
  List<Widget> buildTypeSection(String type) {
    final items = results["by_type"]?[type] ?? [];
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Top 8 for $type',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      ...items.map((item) => ListTile(
            leading: item["IMAGE"] != null
                ? Image.network(item["IMAGE"], width: 50, height: 50)
                : const Icon(Icons.image_not_supported),
            title: Text(item["WHERE_NAME"] ?? "Unknown"),
            subtitle: Text('Rating: ${item["WHERE_RATE"] ?? "N/A"}'),
          )),
    ];
  }

  // 전체 상위 8개 항목을 보여주는 위젯 빌드
  Widget buildOverallSection() {
    final items = results["overall_top_8"] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Overall Top 8',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map((item) => ListTile(
              leading: item["IMAGE"] != null
                  ? Image.network(item["IMAGE"], width: 50, height: 50)
                  : const Icon(Icons.image_not_supported),
              title: Text(item["WHERE_NAME"] ?? "Unknown"),
              subtitle: Text('Rating: ${item["WHERE_RATE"] ?? "N/A"}'),
            )),
      ],
    );
  }
}
