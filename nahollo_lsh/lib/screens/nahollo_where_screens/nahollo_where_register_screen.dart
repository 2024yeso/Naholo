import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/providers/user_provider.dart';

import 'package:http/http.dart' as http;
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_register_search_screen.dart';
import 'package:nahollo/util.dart';
import 'package:provider/provider.dart';

class NaholloWhereRegisterScreen extends StatefulWidget {
  const NaholloWhereRegisterScreen({super.key});

  @override
  State<NaholloWhereRegisterScreen> createState() =>
      _NaholloWhereRegisterScreenState();
}

class _NaholloWhereRegisterScreenState
    extends State<NaholloWhereRegisterScreen> {
  final TextEditingController _memoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  double _rating = 0;
  String _selectedType = "play";
  Map<String, String> _result = {
    'name': "장소를 입력해주세요",
    'address': "",
  };

  final Map<String, bool> _reasons = {
    "1인 메뉴가 좋아요": false,
    "분위기가 좋아요": false,
    "위생관리 잘돼요": false,
    "혼자 즐기 좋은 음식이 있어요": false,
    "대중교통으로 가기 편해요": false,
    "주차 가능해요": false,
    "오래 머물기 좋아요": false,
    "날씨가 좋아요": false,
    "고독할 수 있어요": false,
    "활발히 놀기좋아요": false,
    "사진 찍기 좋아요": false,
    "구경할 거 있어요": false,
  };

  // 새로운 화면을 호출할 때 데이터를 기다리는 코드
  Future<void> _navigateAndGetLocation(BuildContext context) async {
    _result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NaholloWhereRegisterSearchScreen(),
      ),
    );
    setState(() {});
    // 결과를 받아와서 사용하는 부분
    print("받은 데이터: $_result"); // locationData가 출력됩니다.
    // 받은 데이터를 원하는 방식으로 처리합니다.
  }

  Future<void> testAddReview() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    final response = await http.post(
      Uri.parse('${Api.baseUrl}/add_review/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "USER_ID": "${user?.userId}",
        "WHERE_ID": 1,
        "REVIEW_CONTENT": _memoController.text.trim(),
        "WHERE_LIKE": 10,
        "WHERE_RATE": _rating,
        "REASON_MENU": _reasons["1인 메뉴가 좋아요"] ?? false,
        "REASON_MOOD": _reasons["분위기가 좋아요"] ?? false,
        "REASON_SAFE": _reasons["위생관리 잘돼요"] ?? false,
        "REASON_SEAT": _reasons["혼자 즐기 좋은 음식이 있어요"] ?? false,
        "REASON_TRANSPORT": _reasons["대중교통으로 가기 편해요"] ?? false,
        "REASON_PARK": _reasons["주차 가능해요"] ?? false,
        "REASON_LONG": _reasons["오래 머물기 좋아요"] ?? false,
        "REASON_VIEW": _reasons["날씨가 좋아요"] ?? false,
        "REASON_INTERACTION": _reasons["고독할 수 있어요"] ?? false,
        "REASON_QUITE": _reasons["활발히 놀기좋아요"] ?? false,
        "REASON_PHOTO": _reasons["사진 찍기 좋아요"] ?? false,
        "REASON_WATCH": _reasons["구경할 거 있어요"] ?? false,
        "IMAGES": ["scenery1.jpg", "scenery2.jpg"] // 리뷰와 함께 추가할 이미지들
      }),
    );

    if (response.statusCode == 200) {
      print("Add Review Response: ${utf8.decode(response.bodyBytes)}");
    } else {
      print(
          "Add Review Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = pickedFiles.map((e) => File(e.path)).toList();
    });
  }

  Future<void> _submitReview() async {
    await testAddReview();
  }

  @override
  Widget build(BuildContext context) {
    var size = SizeUtil.getScreenSize(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '나홀로 어디? 등록',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '나홀로 어디? 사진 0/20',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImages.isEmpty
                    ? const Center(
                        child: Text('+\n사진 선택', textAlign: TextAlign.center))
                    : Image.file(_selectedImages[0], fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '다녀온 나홀로 어디?',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: () {
                // 장소 선택 로직 추가
                _navigateAndGetLocation(context);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xff7a4fff))),
                width: size.width * 0.9,
                height: size.width * 0.15,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _result["name"]!,
                        style: const TextStyle(
                          color: Color(0xff7a4fff),
                          fontSize: 12,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_outlined,
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              '혼자 뭐하러?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 가로로 스크롤 가능하게 설정
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = "play"; // 혼놀 보기
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(20, 10),
                      backgroundColor: _selectedType == "play"
                          ? const Color(0xFF8A2EC1).withOpacity(0.7)
                          : Colors.white,
                      foregroundColor: _selectedType == "play"
                          ? Colors.white
                          : Colors.black, // 선택된 버튼의 텍스트 색상 변경
                      side: BorderSide(
                        color: _selectedType == "play"
                            ? const Color(0xFF8A2EC1).withOpacity(0.7)
                            : Colors.white, // 테두리 색상 설정
                      ),
                    ),
                    child: const Text("혼놀"),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = "eat"; // 혼밥 보기
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(20, 10),
                      backgroundColor: _selectedType == "eat"
                          ? const Color(0xFF8A2EC1).withOpacity(0.7)
                          : Colors.white,
                      foregroundColor: _selectedType == "eat"
                          ? Colors.white
                          : Colors.black, // 선택된 버튼의 텍스트 색상 변경
                      side: BorderSide(
                        color: _selectedType == "eat"
                            ? const Color(0xFF8A2EC1).withOpacity(0.7)
                            : Colors.white, // 테두리 색상 설정
                      ),
                    ),
                    child: const Text("혼밥"),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = "sleep"; // 혼박 보기
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(20, 10),
                      backgroundColor: _selectedType == "sleep"
                          ? const Color(0xFF8A2EC1).withOpacity(0.7)
                          : Colors.white,
                      foregroundColor: _selectedType == "sleep"
                          ? Colors.white
                          : Colors.black, // 선택된 버튼의 텍스트 색상 변경
                      side: BorderSide(
                        color: _selectedType == "sleep"
                            ? const Color(0xFF8A2EC1).withOpacity(0.7)
                            : Colors.white, // 테두리 색상 설정
                      ),
                    ),
                    child: const Text("혼박"),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = "drink"; // 혼술 보기
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(20, 10),
                      backgroundColor: _selectedType == "drink"
                          ? const Color(0xFF8A2EC1).withOpacity(0.7)
                          : Colors.white,
                      foregroundColor: _selectedType == "drink"
                          ? Colors.white
                          : Colors.black, // 선택된 버튼의 텍스트 색상 변경
                      side: BorderSide(
                        color: _selectedType == "drink"
                            ? const Color(0xFF8A2EC1).withOpacity(0.7)
                            : Colors.white, // 테두리 색상 설정
                      ),
                    ),
                    child: const Text("혼술"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '나홀로 가기 좋은 이유',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Wrap(
              spacing: 3.0,
              runSpacing: 1.0,
              children: _reasons.keys.map((reason) {
                return FilterChip(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // 버튼에 모서리 둥글게 적용
                  ),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 2,
                  ),
                  label: Text(
                    reason,
                    style: const TextStyle(fontSize: 10),
                  ),
                  selected: _reasons[reason]!,
                  onSelected: (bool selected) {
                    setState(() {
                      _reasons[reason] = selected;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              '별점 리뷰',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Container(
                  width: size.width * 0.5,
                  height: size.width * 0.1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 2,
                          spreadRadius: 2,
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: RatingBar.builder(
                      itemSize: 25,
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text('$_rating'),
                const SizedBox(height: 16),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              '나홀로 메모',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _memoController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    '취향에 맞는 장소였나요? 장점의 묘미, 즐길 거리 등 혼자 방문하기 좋은 이유를 기록해보세요.',
                hintStyle: const TextStyle(
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xff7a4fff),
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('나홀로 어디? 등록'),
            ),
          ],
        ),
      ),
    );
  }
}
