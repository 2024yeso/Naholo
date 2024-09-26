import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nahollo/util.dart';

class NaholloWhereDetailScreen extends StatefulWidget {
  Map<String, dynamic> item;

  NaholloWhereDetailScreen({super.key, required this.item});

  @override
  State<NaholloWhereDetailScreen> createState() =>
      _NaholloWhereDetailScreenState();
}

/*{
      "USER_ID": user?.userId ?? 'Unknown', // null일 경우 기본값 제공
      "WHERE_ID": 1,
      "REVIEW_CONTENT": _memoController.text.trim(),
      "WHERE_LIKE": 10,
      "WHERE_RATE": _rating ?? 0.0, // null 방지
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
      "IMAGE": "https://i.imgur.com/tV71llG.jpeg"
    } */

class _NaholloWhereDetailScreenState extends State<NaholloWhereDetailScreen> {
  late final info = widget.item;

  late final Map<String, bool> _reasons = {
    "1인 메뉴가 좋아요": info["REASON_MENU"],
    "분위기가 좋아요": info["REASON_MOOD"],
    "위생관리 잘돼요": info["REASON_SAFE"],
    "혼자 즐기 좋은 음식이 있어요": info["REASON_SEAT"],
    "대중교통으로 가기 편해요": info["REASON_TRANSPORT"],
    "주차 가능해요": info["REASON_PARK"],
    "오래 머물기 좋아요": info["REASON_LONG"],
    "날씨가 좋아요": info["REASON_VIEW"],
    "고독할 수 있어요": info["REASON_INTERACTION"],
    "활발히 놀기좋아요": info["REASON_QUITE"],
    "사진 찍기 좋아요": info["REASON_PHOTO"],
    "구경할 거 있어요": info["REASON_WATCH"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavBar(
        selectedIndex: 0,
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          info["WHERE_NAME"],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(info["IMAGE"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              AutoSizeText(
                "${info["WHERE_NAME"]}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                minFontSize: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              customReason(_reasons),
            ],
          ),
        ),
      ),
    );
  }
}

Widget customReason(Map<String, bool> reason) {
  // value가 true인 key들만 필터링
  List<String> trueKeys = reason.entries
      .where((entry) => entry.value) // value가 true인 것만 필터링
      .map((entry) => entry.key) // key 값만 추출
      .toList(); // 리스트로 변환

  return Wrap(
    spacing: 8.0, // 각 컨테이너 간의 가로 간격
    runSpacing: 4.0, // 각 줄 간의 세로 간격
    children: trueKeys.map((key) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 205, 211, 93).withOpacity(0.2),
              const Color.fromARGB(255, 182, 95, 248).withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              key,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
