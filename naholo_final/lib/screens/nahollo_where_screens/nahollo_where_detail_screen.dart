import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_where_review_data.dart';
import 'package:nahollo/util.dart';

class NaholloWhereDetailScreen extends StatefulWidget {
  Map<String, dynamic> item;

  NaholloWhereDetailScreen({super.key, required this.item});

  @override
  State<NaholloWhereDetailScreen> createState() =>
      _NaholloWhereDetailScreenState();
}

class _NaholloWhereDetailScreenState extends State<NaholloWhereDetailScreen> {
  late final info = widget.item;
  List<Map<String, dynamic>> reviews = []; // 리뷰 리스트

  late final Map<String, int> _reasons = {
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
  String showKoreanText(String reason) {
    if (reason == "MENU") {
      return "1인 메뉴가 좋아요";
    }
    if (reason == "MOOD") {
      return "분위기가 좋아요";
    }
    if (reason == "SAFE") {
      return "위생관리 잘돼요";
    }
    if (reason == "SEAT") {
      return "혼자 즐기 좋은 음식이 있어요";
    }
    if (reason == "TRANSPORT") {
      return "대중교통으로 가기 편해요";
    }
    if (reason == "PARK") {
      return "주차 가능해요";
    }
    if (reason == "LONG") {
      return "오래 머물기 좋아요";
    }
    if (reason == "VIEW") {
      return "날씨가 좋아요";
    }
    if (reason == "INTERACTION") {
      return "고독할 수 있어요";
    }
    if (reason == "QUITE") {
      return "활발히 놀기좋아요";
    }
    if (reason == "PHOTO") {
      return "사진 찍기 좋아요";
    }
    if (reason == "WATCH") {
      return "구경할 거 있어요";
    }

    return "오류"; // 매칭되지 않는 값에 대한 기본 처리
  }

  // WHERE_ID와 일치하는 리뷰를 필터링하여 가져오는 함수
  void fetchReviews() {
    reviews = whereReview["where_review"]
        .where((review) => review["WHERE_ID"] == info["WHERE_ID"])
        .toList();
  }

  // 하트를 눌렀을 때 실행할 함수
  void toggleLike(int index) {
    setState(() {
      if (reviews[index]["isLiked"] == true) {
        reviews[index]["isLiked"] = false;
        reviews[index]["WHERE_LIKE"] -= 1;
      } else {
        reviews[index]["isLiked"] = true;
        reviews[index]["WHERE_LIKE"] += 1;
        print(reviews);
      }
    });
  }

  Widget showItem(reasons) {
    return Wrap(
      spacing: 8.0, // 아이템들 사이의 간격
      children: _reasons.entries
          .where((entry) => entry.value > 0) // value가 0 이상인 항목만 필터링
          .map((entry) {
        return Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.key), // 이유 텍스트
              const SizedBox(width: 5), // 약간의 간격
              Text(
                entry.value.toString(),
                style: TextStyle(color: Colors.grey[600]), // 숫자는 약간 다르게 스타일링
              ),
            ],
          ),
          backgroundColor: Colors.purple[50], // 칩의 배경색
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

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
                width: SizeScaler.scaleSize(context, 197),
                height: SizeScaler.scaleSize(context, 135),
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
              showItem(_reasons),
              Column(
                children: reviews.map((review) {
                  // True인 REASON 값만 필터링
                  final trueReasons = review.entries
                      .where((entry) =>
                          entry.key.startsWith('REASON') && entry.value == true)
                      .map((entry) => entry.key.replaceFirst('REASON_', ''))
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 이미지 스크롤
                          SizedBox(
                            height: SizeScaler.scaleSize(context, 147),
                            width: SizeScaler.scaleSize(context, 147),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: review["IMAGES"].length,
                              itemBuilder: (context, imgIndex) {
                                // 바이트 배열을 가져오기
                                final imageBytes = review["IMAGES"][imgIndex];

                                try {
                                  // 바이트 배열을 Uint8List로 변환
                                  Uint8List byteData =
                                      Uint8List.fromList(imageBytes);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Image.memory(
                                      byteData,
                                      height: SizeScaler.scaleSize(
                                          context, 147), // 정사각형으로 동일한 크기
                                      width: SizeScaler.scaleSize(context, 147),
                                      fit: BoxFit.cover, // 이미지를 정사각형 안에 꽉 채움
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // 이미지 변환 실패 시 에러 아이콘을 보여줌
                                        return const Icon(
                                          Icons.error,
                                          size: 50,
                                          color: Colors.red,
                                        );
                                      },
                                    ),
                                  );
                                } catch (e) {
                                  // 변환 실패 시 실패 아이콘을 표시
                                  return const Icon(
                                    Icons.error,
                                    size: 50,
                                    color: Colors.red,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 리뷰 내용
                          Text(
                            review["REVIEW_CONTENT"],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),

                          // True인 REASON들 표시
                          Wrap(
                            spacing: 8.0,
                            children: trueReasons
                                .map((reason) => Chip(
                                      label: Text(
                                        showKoreanText(reason),
                                      ),
                                      backgroundColor: Colors.purple[50],
                                    ))
                                .toList(),
                          ),

                          // 좋아요 및 하트 이모티콘
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  review["isLiked"] == true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: review["isLiked"] == true
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  toggleLike(reviews.indexOf(review));
                                },
                              ),
                              Text("${review["WHERE_LIKE"]}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
