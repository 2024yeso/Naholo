// widgets/journal_content.dart

import 'package:flutter/material.dart';
import '../models/review.dart';
import '../models/user_profile.dart';

class JournalContent extends StatelessWidget {
  final List<Review> reviews;
  final UserProfile? userProfile;

  JournalContent({required this.reviews, this.userProfile});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(
        child: Text(
          '리뷰가 없습니다.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        
        // 디버그 출력: 각 리뷰의 reason 값 출력
        print('Review #$index: reasonMenu=${review.reasonMenu}, reasonMood=${review.reasonMood}, '
              'reasonSafe=${review.reasonSafe}, reasonSeat=${review.reasonSeat}, '
              'reasonTransport=${review.reasonTransport}, reasonPark=${review.reasonPark}, '
              'reasonLong=${review.reasonLong}, reasonView=${review.reasonView}, '
              'reasonInteraction=${review.reasonInteraction}, reasonQuite=${review.reasonQuiet}, '
              'reasonPhoto=${review.reasonPhoto}, reasonWatch=${review.reasonWatch}');

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 사용자 정보 및 태그
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 20, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile?.nickname ?? '닉네임 없음',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          review.whereLocate,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "최신순",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // 장소 이름 및 리뷰 이미지
                Text(
                  review.whereName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                review.reviewImages != null && review.reviewImages!.isNotEmpty
                    ? Image.memory(
                        review.reviewImages!.first!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text("No Image Available"),
                        ),
                      ),
                SizedBox(height: 8),
                // 리뷰 내용
                Text(
                  review.reviewContent,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                SizedBox(height: 16),
                // 리뷰 태그
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (review.reasonMenu) _buildTag("메뉴가 좋아요", Icons.restaurant_menu),
                    if (review.reasonMood) _buildTag("분위기 좋아요", Icons.thumb_up),
                    if (review.reasonSafe) _buildTag("안전해요", Icons.security),
                    if (review.reasonSeat) _buildTag("자리 여유 있어요", Icons.event_seat),
                    if (review.reasonTransport) _buildTag("교통이 편리해요", Icons.directions_transit),
                    if (review.reasonPark) _buildTag("주차 가능해요", Icons.local_parking),
                    if (review.reasonLong) _buildTag("오래 머물기 좋아요", Icons.hourglass_empty),
                    if (review.reasonView) _buildTag("전망이 좋아요", Icons.visibility),
                    if (review.reasonInteraction) _buildTag("상호작용이 좋아요", Icons.people),
                    if (review.reasonQuiet) _buildTag("조용해요", Icons.volume_off),
                    if (review.reasonPhoto) _buildTag("사진 찍기 좋아요", Icons.camera_alt),
                    if (review.reasonWatch) _buildTag("볼거리 많아요", Icons.theaters),
                  ],
                ),
                SizedBox(height: 16),
                // 좋아요 및 기타 정보
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 4),
                    Text("${review.whereLike}명이 이 일기를 좋아합니다."),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.purple),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.purple),
          ),
        ],
      ),
    );
  }
}
