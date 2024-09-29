import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_detail_screen.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_register_screen.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_where_data.dart';
import 'package:nahollo/test_where_review_data.dart';
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
  final _whereReview = whereReview;
  final _where = where;
  final PageController _pageController =
      PageController(viewportFraction: 0.4, initialPage: 1);
  int _currentPage = 1;

  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  void _updateSearchResults(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        //   _searchResults = List<Map<String, dynamic>>.from(byType["play"]);
      } else {
        _searchResults = _where["where"]
            .where((item) => item["WHERE_NAME"]
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList()
            .cast<Map<String, dynamic>>();
      }
    });
  }

  // WHERE_TYPE에 따라 필터링된 리스트를 반환하는 함수
  List<Map<String, dynamic>> filterByType(String type) {
    // where["where"] 리스트에서 WHERE_TYPE이 주어진 type과 같은 항목들을 필터링하여 반환
    return where["where"].where((item) => item["WHERE_TYPE"] == type).toList();
  }

// SAVE 값이 높은 상위 8개의 항목을 반환하는 함수
  List<Map<String, dynamic>> filterBySave() {
    // 데이터를 복사하여 정렬 후 변경되더라도 원본 데이터를 유지
    List<Map<String, dynamic>> sortedList =
        List<Map<String, dynamic>>.from(where["where"]);

    // SAVE 값을 기준으로 내림차순 정렬
    sortedList.sort((a, b) => b["SAVE"].compareTo(a["SAVE"]));

    // 상위 8개 항목을 추출하여 반환
    return sortedList.take(8).toList();
  }

  String showAdress(String adress) {
    var list = adress.split(' ');
    var result = '${list[0]}, ${list[1]}';
    return result;
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
    _pageController.addListener(() {
      // 현재 가운데 있는 페이지 인덱스를 계산
      setState(() {
        _currentPage = (_pageController.page ?? 0).round();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // 메모리 누수를 방지하기 위해 컨트롤러를 dispose합니다.
    _pageController.dispose();
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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: size.width * 0.15,
                    ),
                    SizedBox(
                      width: SizeScaler.scaleSize(context, 175),
                      height: SizeScaler.scaleSize(context, 24),
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
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  const BorderSide(color: Color(0xff5357df))),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                                color: Color(0xff5357df)), // 비활성 상태의 테두리 색상
                          ),
                        ),
                        onChanged: (value) {
                          _searchQuery = value;
                          _updateSearchResults(_searchQuery);
                        },
                        onSubmitted: (value) {
                          _searchQuery = value;
                          _updateSearchResults(_searchQuery);
                          if (_searchResults.isEmpty) {
                            Fluttertoast.showToast(msg: "검색어가 존재하지 않습니다");
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NaholloWhereDetailScreen(
                                    item: _searchResults[0]),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    _searchResults.isNotEmpty
                        ? Container(
                            decoration: const BoxDecoration(),
                            width: 300,
                            height: 100,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Image.network(
                                      _searchResults[0]['IMAGE'],
                                      width: 50, // 이미지의 적절한 너비 지정
                                      height: 50, // 이미지의 적절한 높이 지정
                                      fit: BoxFit.cover, // 이미지가 적절히 맞춰지도록 설정
                                    ),
                                    Expanded(
                                      child: ListTile(
                                        title: Text(
                                            _searchResults[0]['WHERE_NAME']),
                                        subtitle: Text(
                                            _searchResults[0]['WHERE_LOCATE']),
                                        onTap: () {
                                          // 검색 결과 항목 클릭 시 다음 화면으로 이동
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  NaholloWhereDetailScreen(
                                                      item: _searchResults[
                                                          index]),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        : Container(),

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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${user!.nickName}를 위한\n장소를 추천해줄께-!",
                                        style: TextStyle(
                                          fontSize:
                                              SizeScaler.scaleSize(context, 12),
                                          fontWeight: FontWeight.w600,
                                          color: darkpurpleColor,
                                        ),
                                      ),
                                      const Text(
                                        "전국 핫플 혼놀 장소",
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Image.asset(
                                    "assets/images/${user.userCharacter}.png",
                                    width: SizeScaler.scaleSize(context, 80),
                                    height:
                                        SizeScaler.scaleSize(context, 800 / 9),
                                  )
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
                          width: size.width * 0.15,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "글쓰기",
                                style: TextStyle(
                                    fontSize: SizeScaler.scaleSize(context, 8),
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.create_outlined,
                                color: Colors.white,
                                size: SizeScaler.scaleSize(context, 8.5),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeScaler.scaleSize(context, 20),
                  )
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
    final items = filterByType(type);

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
                          showAdress(item["WHERE_LOCATE"]),
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
    final items = filterBySave();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 가로 스크롤이 가능한 리스트뷰
        SizedBox(
          height: 300, // 이미지와 텍스트가 잘 보이도록 높이 설정
          child: PageView.builder(
            controller: _pageController,
            itemCount: items.isEmpty ? 0 : null,
            itemBuilder: (context, index) {
              final item = items[index % items.length];
              double scale = _currentPage == index ? 1.0 : 0.8;
              double opacity = _currentPage == index ? 1.0 : 0.5;

              return AnimatedBuilder(
                animation: PageController(viewportFraction: 0.3),
                builder: (context, child) {
                  return Transform.scale(
                    scale: scale, // 이 부분을 조정하여 중간 항목을 확대할 수 있음
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NaholloWhereDetailScreen(item: item),
                      ),
                    );
                  },
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
                      if (_currentPage == index)
                        Column(
                          children: [
                            const SizedBox(
                              height: 2,
                            ),
                            const AutoSizeText(
                              "장소를 더 보려면 탭 하세요",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              maxLines: 1, // 최대 줄 수 설정
                              minFontSize: 8, // 최소 폰트 크기 설정
                            ),
                            Text(
                              item["WHERE_NAME"] ?? "Unknown",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on_sharp,
                                  size: 13,
                                ),
                                Text(
                                  showAdress(item["WHERE_LOCATE"]),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w200),
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
      width: SizeScaler.scaleSize(context, 33),
      height: SizeScaler.scaleSize(context, 13),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xff4722BC), Color(0xffC17AFF)],
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
