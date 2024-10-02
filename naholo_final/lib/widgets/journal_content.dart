// widgets/journal_content.dart

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_register_screen.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_where_review_data.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../models/user_profile.dart';

class JournalContent extends StatefulWidget {
  final List<Map<String, dynamic>> reviews;
  final UserProfile? userProfile;

  const JournalContent({super.key, required this.reviews, this.userProfile});

  @override
  State<JournalContent> createState() => _JournalContentState();
}

class _JournalContentState extends State<JournalContent> {
  String getLocationParts(Map<String, dynamic> review) {
    String location = review["WHERE_LOCATE"];
    List<String> locationParts = location.split(' ');

    // 인덱스가 존재하는지 확인 후 처리
    String part1 = locationParts.length > 1 ? locationParts[1] : "정보없음";
    String part2 = locationParts.length > 2 ? ", ${locationParts[2]}" : "";

    return "$part1$part2";
  }

  @override
  Widget build(BuildContext context) {
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
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.reviews.length,
        itemBuilder: (context, index) {
          final review = widget.reviews[index];

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
                  // 상단 사용자 정보 및 태그
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person,
                            size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userProfile?.nickname ?? '닉네임 없음',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            getLocationParts(review),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 장소 이름 및 리뷰 이미지
                  Text(
                    review["WHERE_NAME"],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // 이미지 스크롤
                  SizedBox(
                    height: SizeScaler.scaleSize(context, 147),
                    width: SizeScaler.scaleSize(context, 147),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: review["REVIEW_IMAGE"].length,
                      itemBuilder: (context, imgIndex) {
                        // 바이트 배열을 가져오기
                        final imageBytes = review["REVIEW_IMAGE"][imgIndex];

                        try {
                          // 바이트 배열을 Uint8List로 변환
                          Uint8List byteData = Uint8List.fromList(imageBytes);

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Image.memory(
                              byteData,
                              height: SizeScaler.scaleSize(
                                  context, 147), // 정사각형으로 동일한 크기
                              width: SizeScaler.scaleSize(context, 147),
                              fit: BoxFit.cover, // 이미지를 정사각형 안에 꽉 채움
                              errorBuilder: (context, error, stackTrace) {
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
