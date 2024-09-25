import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_detail_screen.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_register_screen.dart';
import 'package:nahollo/test_data.dart';
import 'package:nahollo/util.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class NaholloWhereMainScreen extends StatefulWidget {
  const NaholloWhereMainScreen({super.key});

  @override
  State<NaholloWhereMainScreen> createState() => _NaholloWhereMainScreenState();
}

class _NaholloWhereMainScreenState extends State<NaholloWhereMainScreen> {
  final int _selectedIndex = 0; // 선택된 인덱스
  Map<String, dynamic> results = {}; // 데이터를 저장할 변수
  String _selectedType = "overall"; // 현재 선택된 타입 ("overall"이 기본값)
  final _bytype = byType;
  final _overall = overall;
  final PageController _pageController =
      PageController(viewportFraction: 0.5, initialPage: 4);
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  void _updateSearchResults(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _searchResults = List<Map<String, dynamic>>.from(byType["play"]);
      } else {
        _searchResults = byType["play"]
            .where((item) => item["WHERE_NAME"]
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList()
            .cast<Map<String, dynamic>>();
      }
    });
  }

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
  void dispose() {
    _searchController.dispose(); // 메모리 누수를 방지하기 위해 컨트롤러를 dispose합니다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = context.read<UserProvider>();
    var user = userProvider.user;

    var size = SizeUtil.getScreenSize(context);

    return Scaffold(
      backgroundColor: const Color(0xfff0f1ff),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: size.width * 0.15,
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      height: size.width * 0.15,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '장소를 검색해 보세요',
                          hintStyle: const TextStyle(color: Color(0xff5357df)),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xff5357df),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                                  const BorderSide(color: Color(0xff5357df))),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: Color(0xff5357df)), // 비활성 상태의 테두리 색상
                          ),
                        ),
                        onChanged: (value) {},
                        onSubmitted: (value) {
                          _searchQuery = value;
                          _updateSearchResults(_searchQuery);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NaholloWhereDetailScreen(
                                  item: _searchResults[0]),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // 가로로 스크롤 가능하게 설정
                      child: Row(
                        children: [
                          GradientElevatedButton(
                            label: "전체",
                            isSelected: _selectedType == "overall",
                            onPressed: () {
                              setState(() {
                                _selectedType = "overall"; // 전체 보기
                              });
                            },
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          GradientElevatedButton(
                            label: "혼놀",
                            isSelected: _selectedType == "play",
                            onPressed: () {
                              setState(() {
                                _selectedType = "play"; // 전체 보기
                              });
                            },
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          GradientElevatedButton(
                            label: "혼밥",
                            isSelected: _selectedType == "eat",
                            onPressed: () {
                              setState(() {
                                _selectedType = "eat"; // 전체 보기
                              });
                            },
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          GradientElevatedButton(
                            label: "혼박",
                            isSelected: _selectedType == "sleep",
                            onPressed: () {
                              setState(() {
                                _selectedType = "sleep"; // 전체 보기
                              });
                            },
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          GradientElevatedButton(
                            label: "혼술",
                            isSelected: _selectedType == "drink",
                            onPressed: () {
                              setState(() {
                                _selectedType = "drink"; // 전체 보기
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    _selectedType == "overall"
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${user!.nickName}를 위한\n장소를 추천해줄께-!",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: darkpurpleColor,
                                    ),
                                  ),
                                  Image.asset(
                                    "assets/images/${user.userCharacter}.png",
                                    width: size.width * 0.3,
                                    height: size.width * 0.3,
                                  )
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "전국 핫플 혼놀 장소",
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                            ],
                          )
                        : const SizedBox(
                            height: 1,
                          ), // _selectedType이 "overall"이 아닐 때 보여줄 위젯

                    _selectedType == "overall"
                        ? buildOverallSection()
                        : buildTypeSection(_selectedType, size),

                    /*         results.isEmpty
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
                          ),  */
                  ],
                ),
              ),
              Column(
                children: [
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff7a4fff),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NaholloWhereRegisterScreen(),
                          ),
                        ),
                        child: SizedBox(
                          width: size.width * 0.2,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "글쓰기",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                              Icon(
                                Icons.create_outlined,
                                color: Colors.white,
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 특정 타입별로 상위 항목을 보여주는 위젯 빌드
  Widget buildTypeSection(String type, Size size) {
    final items = byType[type] ?? [];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 한 행에 두 개씩 표시
        crossAxisSpacing: 2,
        mainAxisSpacing: 3,
        childAspectRatio: 0.7, // 아이템의 가로세로 비율 설정
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final shotAdress = item["WHERE_LOCATE"].split(' ')[0]; //+
        // item["WHERE_LOCATE"].split(' ')[2]; 주소 길어지면 활성화
        return GestureDetector(
          onTap: () {
            // 카드 클릭 시 세부 정보 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NaholloWhereDetailScreen(item: item), // 아이템 정보 전달
              ),
            );
          },
          child: Card(
            elevation: 0,
            color: const Color(0xfff0f1ff),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지를 보여주는 부분
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: item["IMAGE"] != null
                      ? Image.network(
                          item["IMAGE"],
                          width: size.width * 0.4,
                          height: size.width * 0.45,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported, size: 50),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      item["WHERE_NAME"] ?? "Unknown",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      minFontSize: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_sharp,
                          size: 13,
                        ),
                        AutoSizeText(
                          '${shotAdress ?? "N/A"}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black,
                              fontWeight: FontWeight.w200),
                          maxLines: 1, // 최대 라인 수
                          minFontSize: 8, // 최소 글자 크기
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildOverallSection() {
    final items = _overall["overall_top_8"] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 가로 스크롤이 가능한 리스트뷰
        SizedBox(
          height: 200, // 이미지와 텍스트가 잘 보이도록 높이 설정
          child: PageView.builder(
            controller: _pageController,
            itemCount: items.length == 0 ? 0 : null,
            itemBuilder: (context, index) {
              final item = items[index % items.length];
              print("ㅇ?? $index");
              return AnimatedBuilder(
                animation: PageController(viewportFraction: 0.6),
                builder: (context, child) {
                  print("이거 뭐임 $child");
                  return Transform.scale(
                    scale: 1.0, // 이 부분을 조정하여 중간 항목을 확대할 수 있음
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      item["IMAGE"] != null
                          ? Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // 그림자 색상 및 투명도
                                  spreadRadius: 2, // 그림자 퍼지는 정도
                                  blurRadius: 6, // 그림자의 흐림 정도
                                  offset: const Offset(6, 5), // 그림자 위치 (x, y)
                                ),
                              ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  item["IMAGE"]!,
                                  width: 100,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : const Icon(Icons.image_not_supported, size: 50),
                      Text(
                        item["WHERE_NAME"] ?? "Unknown",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_sharp,
                            size: 13,
                          ),
                          Text(
                            '${item["WHERE_LOCATE"] ?? "N/A"}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black,
                                fontWeight: FontWeight.w200),
                          ),
                        ],
                      ), /* ListView.builder(
            scrollDirection: Axis.horizontal, // 가로 스크롤 설정
            itemCount:
                items.length == 0 ? 0 : null, // 무한 스크롤을 위해 itemCount를 null로 설정
            itemBuilder: (context, index) {
              // 무한 스크롤을 위해 인덱스를 리스트 길이로 나눈 나머지 값 사용
              final item = items[index % items.length]; 
              final imageUrl = item["IMAGE"];
              final placeName = item["WHERE_NAME"] ?? "Unknown";
              final location = item["WHERE_LOCATE"] ?? "N/A";

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    // 이미지를 보여주는 부분
                    imageUrl != null
                        ? Image.network(
                            imageUrl,
                            width: 70,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported, size: 50),  
                    // 장소 이름과 위치를 보여주는 부분
                    Text(placeName, style: const TextStyle(fontSize: 12)),
                    Text(
                      '위치: $location',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ), */
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class GradientElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const GradientElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final size = SizeUtil.getScreenSize(context);
    return Container(
      width: size.width * 0.25,
      height: size.width * 0.1,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF8A2EC1), Color(0xFFDCA1E7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null, // 선택되지 않은 경우 그라데이션 없이
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(10, 5),
          backgroundColor: Colors.transparent, // 배경 투명
          foregroundColor: isSelected ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          shadowColor: Colors.transparent, // 그림자 제거
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey,
            ),
          ),
        ),
        child: AutoSizeText(
          label,
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          minFontSize: 5,
        ),
      ),
    );
  }
}
