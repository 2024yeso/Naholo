// widgets/journal_content.dart

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_register_screen.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_where_review_data.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../models/user_profile.dart';
import 'package:http/http.dart' as http;

class JournalContent extends StatefulWidget {
  final List<Map<String, dynamic>> reviews;
  final List<String>? reviewImages;
  final UserProfile? userProfile;

  const JournalContent(
      {super.key, required this.reviews, this.userProfile, this.reviewImages});

  @override
  State<JournalContent> createState() => _JournalContentState();
}

class _JournalContentState extends State<JournalContent> {
  late List<Map<String, dynamic>> reviews = widget.reviews;

  String getLocationParts(Map<String, dynamic> review) {
    String location = review["WHERE_LOCATE"];
    List<String> locationParts = location.split(' ');

    // 인덱스가 존재하는지 확인 후 처리
    String part1 = locationParts.length > 1 ? locationParts[1] : "정보없음";
    String part2 = locationParts.length > 2 ? ", ${locationParts[2]}" : "";

    return "$part1$part2";
  }

  // 이유 목록과 대응되는 한글 텍스트 맵
  final Map<String, String> reasonTextMap = {
    "MENU": "1인 메뉴가 좋아요",
    "MOOD": "분위기가 좋아요",
    "SAFE": "위생관리 잘돼요",
    "SEAT": "좌석이 편해요",
    "TRANSPORT": "대중교통으로 가기 편해요",
    "PARK": "주차 가능해요",
    "LONG": "오래 머물기 좋아요",
    "VIEW": "경치가 좋아요",
    "INTERACTION": "교류하기 좋아요",
    "QUITE": "조용해요",
    "PHOTO": "사진 찍기 좋아요",
    "WATCH": "구경할 거 있어요",
  };

  @override
  Widget build(BuildContext context) {
    print(reviews);
    if (widget.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: SizeScaler.scaleSize(context, 40),
            ),
            Text(
              '아직 등록한 장소가 없어요.',
              style: TextStyle(
                  fontSize: SizeScaler.scaleSize(context, 9),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff000B83)),
            ),
            Text(
              '나만 아는 혼놀 장소를 등록해보세요!',
              style: TextStyle(
                  fontSize: SizeScaler.scaleSize(context, 9),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff000B83)),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 15),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NaholloWhereRegisterScreen(),
                ),
              ),
              child: Container(
                width: SizeScaler.scaleSize(context, 105),
                height: SizeScaler.scaleSize(context, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xffA625FF).withOpacity(0.5),
                      const Color(0xff5C60F4).withOpacity(0.5)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    "나홀로 어디? 등록하기",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeScaler.scaleSize(context, 8)),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return // 리뷰 리스트
          Column(
        children: reviews.map((review) {
          // True인 REASON 값만 필터링
          final trueReasons = reasonTextMap.entries
              .where((entry) =>
                  review['REASON_${entry.key}'] == true ||
                  review['REASON_${entry.key}'] == 1)
              .map((entry) => entry.value)
              .toList();

          // 리뷰의 이미지 리스트 가져오기
          List<dynamic> reviewImages = [];
          if (review["REVIEW_IMAGES"] != null &&
              review["REVIEW_IMAGES"].isNotEmpty) {
            reviewImages = review["REVIEW_IMAGES"];
          }

          print("ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ${review["WHERE_LIKE"]}");

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 상단 사용자 정보 및 태그
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${review["WHERE_NAME"]}",
                          style: TextStyle(
                              color: const Color(0xff542772),
                              fontSize: SizeScaler.scaleSize(context, 10),
                              fontWeight: FontWeight.bold),
                        ),
                        AutoSizeText(
                          minFontSize: 2,
                          getLocationParts(review),
                          style: TextStyle(
                              fontSize: SizeScaler.scaleSize(context, 6),
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeScaler.scaleSize(context, 6),
                  ),
                  // 이미지 스크롤
                  if (reviewImages.isNotEmpty)
                    SizedBox(
                      height: SizeScaler.scaleSize(context, 147),
                      width: SizeScaler.scaleSize(context, 147),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: reviewImages.length,
                        itemBuilder: (context, imgIndex) {
                          print("갯수 ${reviewImages.length}");
                          // 이미지 데이터를 가져오기
                          final imageData = reviewImages[imgIndex];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: buildImage(
                              imageData,
                              SizeScaler.scaleSize(context, 147),
                              SizeScaler.scaleSize(context, 147),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 15),
                  // 리뷰 내용
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      review["REVIEW_CONTENT"],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xff7e7e7e),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // True인 REASON들 표시
                  Wrap(
                    spacing: 6.0,
                    children: trueReasons
                        .map((reason) => Padding(
                              padding: EdgeInsets.only(
                                bottom: SizeScaler.scaleSize(context, 3),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0), // Chip의 패딩과 유사하게 설정
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color:
                                        const Color(0xff7e7e7e), // 검정색 테두리 추가
                                    width: 1.0, // 테두리 두께 설정
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      20), // Chip과 같은 둥근 모서리
                                ),
                                child: Text(reason,
                                    style: TextStyle(
                                        fontSize:
                                            SizeScaler.scaleSize(context, 6),
                                        color: const Color(
                                            0xff7e7e7e))), // 텍스트 스타일
                              ),
                            ))
                        .toList(),
                  ),

                  // 좋아요 및 하트 이모티콘
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: review["WHERE_LIKE"] != 0
                            ? Colors.red
                            : Colors.grey,
                      ),
                      Text(
                        "${review["WHERE_LIKE"] ?? 0}명이 이 후기를 좋아합니다",
                        style: const TextStyle(color: Color(0xff7e7e7e)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ); /* ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.reviews.length,
        itemBuilder: (context, index) {
          final review = widget.reviews[index];
          print("뭐죠? ${widget.reviews}");
          print("왓더 ${review["REVIEW_IMAGE"]}");
          // 디버그 출력: 각 리뷰의 reason 값 출력
          /*
        print('Review #$index: reasonMenu=${review.reasonMenu}, reasonMood=${review.reasonMood}, '
              'reasonSafe=${review.reasonSafe}, reasonSeat=${review.reasonSeat}, '
              'reasonTransport=${review.reasonTransport}, reasonPark=${review.reasonPark}, '
              'reasonLong=${review.reasonLong}, reasonView=${review.reasonView}, '
              'reasonInteraction=${review.reasonInteraction}, reasonQuite=${review.reasonQuiet}, '
              'reasonPhoto=${review.reasonPhoto}, reasonWatch=${review.reasonWatch}');
*/
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // 장소 이름 및 리뷰 이미지
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review["WHERE_NAME"],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(getLocationParts(review),
                          style: TextStyle(
                              fontSize: SizeScaler.scaleSize(context, 7),
                              fontWeight: FontWeight.w400))
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 이미지 스크롤
                  SizedBox(
                    height: SizeScaler.scaleSize(context, 147),
                    width: SizeScaler.scaleSize(context, 147),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 1,
                      itemBuilder: (context, imgIndex) {
              

                        try {
                          return buildImage(
                            review["REVIEW_IMAGE"],
                            SizeScaler.scaleSize(context, 147),
                            SizeScaler.scaleSize(context, 147),
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
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  // 리뷰 태그
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (review["REASON_MENU"] == 1)
                        _buildTag("메뉴가 좋아요", Icons.restaurant_menu),
                      if (review["REASON_MOOD"] == 1)
                        _buildTag("분위기 좋아요", Icons.thumb_up),
                      if (review["REASON_SAFE"] == 1)
                        _buildTag("안전해요", Icons.security),
                      if (review["REASON_SEAT"] == 1)
                        _buildTag("자리 여유 있어요", Icons.event_seat),
                      if (review["REASON_TRANSPORT"] == 1)
                        _buildTag("교통이 편리해요", Icons.directions_transit),
                      if (review["REASON_PARK"] == 1)
                        _buildTag("주차 가능해요", Icons.local_parking),
                      if (review["REASON_LONG"] == 1)
                        _buildTag("오래 머물기 좋아요", Icons.hourglass_empty),
                      if (review["REASON_VIEW"] == 1)
                        _buildTag("전망이 좋아요", Icons.visibility),
                      if (review["REASON_INTERACTION"] == 1)
                        _buildTag("상호작용이 좋아요", Icons.people),
                      if (review["REASON_QUITE"] == 1)
                        _buildTag("조용해요", Icons.volume_off),
                      if (review["REASON_PHOTO"] == 1)
                        _buildTag("사진 찍기 좋아요", Icons.camera_alt),
                      if (review["REASON_WATCH"] == 1)
                        _buildTag("볼거리 많아요", Icons.theaters),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 좋아요 및 기타 정보
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red),
                      const SizedBox(width: 4),
                      Text("${review["WHERE_LIKE"]}명이 이 일기를 좋아합니다."),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } */
    }
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.purple),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.purple),
          ),
        ],
      ),
    );
  }
}

// 이미지 데이터를 표시하는 위젯
Widget buildImage(dynamic imageData, double width, double height) {
  if (imageData != null) {
    if (imageData is String && imageData.isNotEmpty) {
      // Base64 데이터가 'data:image' 접두사를 가지고 있는지 확인 후 제거
      String base64String = imageData;
      if (imageData.startsWith('data:image')) {
        base64String = imageData.split(',').last;
      }

      try {
        // Base64 데이터를 디코딩
        Uint8List imageBytes = base64Decode(base64String);

        // 디버그 로그로 디코딩된 이미지 크기 확인
        print('Decoded image size: ${imageBytes.length} bytes');

        // 디코딩된 이미지가 유효한지 확인하기 위해 메모리에 로드
        return Image.memory(
          imageBytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 디코딩에 실패하거나 이미지 로딩 중 에러 발생 시 대체 이미지 표시
            print('Error displaying image: $error');
            return Image.asset(
              'assets/images/default_image.png',
              width: width,
              height: height,
              fit: BoxFit.cover,
            );
          },
        );
      } catch (e) {
        print('Base64 decoding error: $e');
        return Image.asset(
          'assets/images/default_image.png',
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      }
    } else if (imageData is Uint8List || imageData is List<int>) {
      // Uint8List 또는 List<int>인 경우
      Uint8List imageBytes =
          imageData is Uint8List ? imageData : Uint8List.fromList(imageData);
      return Image.memory(
        imageBytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error displaying image: $error');
          return Image.asset(
            'assets/images/default_image.png',
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // 지원하지 않는 데이터 타입인 경우 대체 이미지 표시
      print('Unsupported image data type: ${imageData.runtimeType}');
      return Image.asset(
        'assets/images/default_image.png',
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
  } else {
    // 이미지 데이터가 없을 경우 기본 이미지 표시
    print('No image data provided.');
    return Image.asset(
      'assets/images/default_image.png',
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
