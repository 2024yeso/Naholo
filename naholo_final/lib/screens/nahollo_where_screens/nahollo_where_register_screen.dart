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
    // 받은 데이터를 원하는 방식으로 처리합니다.
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = pickedFiles.map((e) => File(e.path)).toList();
    });
  }

  void _submitWhere(Map<String, dynamic> result) {
    //where에 데이터 추가 함수
    // 초기값으로 중복 여부를 false로 설정
    bool isDuplicate = false;
    // 현재 데이터의 where 리스트를 가져옴
    List<dynamic> whereList = where["where"];
    // 리스트를 순회하면서 중복 여부 검사
    for (var element in whereList) {
      // WHERE_ID 중복 검사
      if (element["WHERE_ID"] == result["placeId"]) {
        isDuplicate = true;
        print("중복된 WHERE_ID가 발견되었습니다: ${result["placeId"]}");
        break; // 중복 발견 시 더 이상 검사하지 않고 종료
      }
    }
    // 중복되지 않았을 때만 실행
    if (!isDuplicate) {
      print(result);
      print(where["where"]);
      print("중복되지 않은 데이터: 실행 가능");

      String placeId = result["placeId"];
      Double lat = result["lat"];
      Double lng = result["lng"];

      // ensure placeId, lat, and lng are valid types
      where["where"].add({
        "WHERE_TYPE": _selectedType.toString(),
        "WHERE_ID":
            placeId, //result["placeId"]?.toString() ?? "", // placeId를 String으로 변환
        "WHERE_NAME":
            result["name"]?.toString() ?? "Unknown", // String으로 변환 및 기본값 추가
        "WHERE_LOCATE":
            result["address"]?.toString() ?? "Unknown", // String으로 변환 및 기본값 추가
        "REASON_MENU": 0,
        "REASON_MOOD": 0,
        "REASON_SAFE": 0,
        "REASON_SEAT": 0,
        "REASON_TRANSPORT": 0,
        "REASON_PARK": 0,
        "REASON_LONG": 0,
        "REASON_VIEW": 0,
        "REASON_INTERACTION": 0,
        "REASON_QUITE": 0,
        "REASON_PHOTO": 0,
        "REASON_WATCH": 0,
        "IMAGE": result['photoUrl']?.toString() ?? "", // 이미지 URL을 String으로 변환
        "WHERE_RATE": 0.0, // 기본값을 float로
        "LATITUDE": lat, //is double ? result["lat"] : 0.0, // lat을 double로 변환
        "LONGITUDE": lng, //is double ? result["lng"] : 0.0, // lng을 double로 변환
        "SAVE": 0, // 저장 횟수 기본값 설정
      });
    } else {
      print("중복된 where_id 또는 placeId가 발견되었습니다.");
    }
  }

  Future<void> _submitReview() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    // 데이터 추가 시 null 체크 및 기본값 제공
    whereReview["where_review"].add({
      "USER_ID": user?.userId ?? 'Unknown', // null일 경우 기본값 제공
      "WHERE_ID": _result["placeId"],
      "REVIEW_CONTENT": _memoController.text.trim(),
      "WHERE_LIKE": 0,
      "WHERE_RATE": _rating, // null 방지
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
      "WHERE_NAME": _result["name"] ?? "Unknown", // null일 경우 기본값 제공
      "WHERE_LOCATE": _result["address"] ?? "Unknown", // null일 경우 기본값 제공
      "IMAGE": [],
    });

    Navigator.pop(context);
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
        padding: EdgeInsets.symmetric(
          vertical: SizeScaler.scaleSize(context, 15),
          horizontal: SizeScaler.scaleSize(context, 15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '나홀로 어디? 사진 ${_selectedImages.length}/10',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 10),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 12),
            ),
            Wrap(
              spacing: 3.0,
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
                          color: Colors.grey.withOpacity(0.5),
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
                  width: SizeScaler.scaleSize(context, 15),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_result["name"] == "장소를 입력해주세요") {
                  Fluttertoast.showToast(msg: "장소를 입력해주세요!");
                } else {
                  _submitWhere(_result);
                  _submitReview();
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
          ],
        ),
      ),
    );
  }
}
