import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/providers/user_provider.dart';

import 'package:http/http.dart' as http;
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_main_screen.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_register_search_screen.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_where_data.dart';
import 'package:nahollo/test_where_review_data.dart';
import 'package:nahollo/util.dart';
import 'package:provider/provider.dart';

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:nahollo/sizeScaler.dart';
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

  Map<String, dynamic> _result = {
    'name': "장소를 입력해주세요",
    'address': "",
    'photoUrl': "", // 장소 사진 URL 추가
    'placeId': "", //장소 고유값
    'lat': 0.0,
    "lng": 0.0,
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
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = pickedFiles.map((e) => File(e.path)).toList();
    });
  }

  Future<void> _submitReview() async {
    print('아녕어어어녕');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    // 이미지들을 Base64로 인코딩
    List<String> base64Images = [];
    for (File image in _selectedImages) {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }
    String userId = user!.userId;
    String whereId = _result["placeId"];
    String content = _memoController.text.trim().toString();
    String name = _result["name"];
    String locate = _result["address"];
    String whereType = _selectedType;
    double? lat = _result["lat"];
    double? lng = _result["lng"];

    Map<String, dynamic> reviewData = {
      "user_id": userId,
      "where_id": whereId,
      "where_name": name,
      "where_locate": locate,
      "where_type": whereType,
      "where_image": _result["photoUrl"],
      "latitude": lat,
      "longitude": lng,
      "review_content": content,
      "where_like": 0,
      "where_rate": _rating,
      "reason_menu": _reasons["1인 메뉴가 좋아요"] ?? false,
      "reason_mood": _reasons["분위기가 좋아요"] ?? false,
      "reason_safe": _reasons["위생관리 잘돼요"] ?? false,
      "reason_seat": _reasons["혼자 즐기 좋은 음식이 있어요"] ?? false,
      "reason_transport": _reasons["대중교통으로 가기 편해요"] ?? false,
      "reason_park": _reasons["주차 가능해요"] ?? false,
      "reason_long": _reasons["오래 머물기 좋아요"] ?? false,
      "reason_view": _reasons["날씨가 좋아요"] ?? false,
      "reason_interaction": _reasons["고독할 수 있어요"] ?? false,
      "reason_quite": _reasons["활발히 놀기좋아요"] ?? false,
      "reason_photo": _reasons["사진 찍기 좋아요"] ?? false,
      "reason_watch": _reasons["구경할 거 있어요"] ?? false,
      "images": base64Images,
    };

    try {
      var url = Uri.parse('${Api.baseUrl}/add_review/');

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reviewData),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "리뷰가 성공적으로 등록되었습니다.");
      } else {
        print("Failed to submit review: ${response.statusCode}");
        Fluttertoast.showToast(msg: "리뷰 등록에 실패하였습니다.");
      }
    } catch (e) {
      print("Error submitting review: $e");
      Fluttertoast.showToast(msg: "리뷰 등록 중 오류가 발생하였습니다.");
    }
  }

  Future<void> increaseUserExp(int additionalExp) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;
    final currentExp = userProvider.user!.exp;
    final currentLv = userProvider.user!.lv;

    int newLv = currentLv;
    // 새로운 exp 값 계산
    int newExp = currentExp + additionalExp;

    if (newExp >= 100) {
      newExp = newExp - 100;
      newLv += 1;
    }

    final url = Uri.parse('${Api.baseUrl}/update_user/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'EXP': newExp.toString(), // 서버에 보낼 exp 값
          "LV": newLv.toString(),
        }),
      );

      if (response.statusCode == 200) {
        // exp가 성공적으로 업데이트된 경우
        final data = jsonDecode(response.body);
        print('유저 정보 업데이트 성공: ${data['message']}');

        // 로컬 상태에서도 exp 값을 업데이트
        userProvider.updateUserExp(newExp);
        userProvider.updateUserLv(newLv);
      } else {
        print('유저 정보 업데이트 실패: ${response.body}');
      }
    } catch (e) {
      print('유저 정보 업데이트 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = SizeUtil.getScreenSize(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '나홀로 어디? 등록',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: SizeScaler.scaleSize(context, 15),
          horizontal: SizeScaler.scaleSize(context, 15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '나홀로 어디? 사진 ${_selectedImages.length}/10',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 5),
            ),

            // 이미지 리스트를 가로 스크롤로 보여주는 부분
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 가로 스크롤을 허용
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                          child: Text('+\n사진 선택', textAlign: TextAlign.center)),
                    ),
                  ),
                  ..._selectedImages.map((image) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.file(
                            image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 15),
            ),
            const Text(
              '다녀온 나홀로 어디?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 8),
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
            SizedBox(
              height: SizeScaler.scaleSize(context, 15),
            ),
            const Text(
              '혼자 뭐하러?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 5),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 가로로 스크롤 가능하게 설정
              child: Row(
                children: [
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
            SizedBox(
              height: SizeScaler.scaleSize(context, 20),
            ),
            const Text(
              '나홀로 가기 좋은 이유',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 12),
            ),
            Wrap(
              spacing: 6.0,
              runSpacing: 1.0,
              children: _reasons.keys.map((reason) {
                return FilterChip(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // 버튼에 모서리 둥글게 적용
                    side: BorderSide(
                      color: _reasons[reason]!
                          ? const Color(0xff794FFF)
                          : Colors.black,
                    ),
                  ),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 2,
                  ),
                  label: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 10,
                      color: _reasons[reason]!
                          ? const Color(0xff794FFF)
                          : Colors.black,
                    ),
                  ),
                  selected: _reasons[reason]!,
                  backgroundColor: Colors.white, // 기본 배경색 흰색
                  selectedColor: const Color(0xffD8CBFF), // 선택된 상태에서의 배경색 보라색
                  onSelected: (bool selected) {
                    setState(() {
                      _reasons[reason] = selected;
                    });
                  },
                  side: const BorderSide(
                    color: Colors.black, // 검정 테두리 유지
                  ),
                );
              }).toList(),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 15),
            ),
            const Text(
              '별점 리뷰',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 10),
            ),
            Row(
              children: [
                Container(
                  width: SizeScaler.scaleSize(context, 99),
                  height: SizeScaler.scaleSize(context, 19),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: const Offset(2, 2),
                          blurRadius: 2,
                          spreadRadius: 2,
                        )
                      ]),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: RatingBar.builder(
                        itemSize: 25,
                        initialRating: 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(
                          horizontal: SizeScaler.scaleSize(context, 2),
                        ), // 별 사이의 간격 조정
                        itemBuilder: (context, _) => Image.asset(
                          "assets/images/star.png",
                          height: SizeScaler.scaleSize(context, 17),
                          width: SizeScaler.scaleSize(context, 17),
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: SizeScaler.scaleSize(context, 9),
                ),
                Text(
                  '$_rating',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 20),
            ),
            const Text(
              '나홀로 메모',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 10),
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
                contentPadding: EdgeInsets.symmetric(
                    horizontal: SizeScaler.scaleSize(context, 15),
                    vertical: SizeScaler.scaleSize(context, 10)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: SizeScaler.scaleSize(context, 13)),
            SizedBox(
              width: SizeScaler.scaleSize(context, 197),
              child: ElevatedButton(
                onPressed: () async {
                  if (_rating == 0) {
                    Fluttertoast.showToast(msg: "별점을 입력해주세요!");
                  } else {
                    if (_result["name"] == "장소를 입력해주세요") {
                      Fluttertoast.showToast(msg: "장소를 입력해주세요!");
                    } else {
                      print('리뷰 등록 중...');
                      await _submitReview(); // 리뷰 등록

                      print('리뷰 등록 완료, 경험치 증가 시작...');
                      await increaseUserExp(50); // 경험치 증가
                      print('경험치 증가 완료!');
                      print("프로필 수정 완료, Navigator.pop 호출 직전"); // 로그 추가
                      Navigator.pop(
                          context, true); // 수정 성공 후 true 값을 반환하며 화면 닫기
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xff7a4fff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('나홀로 어디? 등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
