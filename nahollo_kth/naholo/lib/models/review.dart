// models/review.dart

import 'dart:convert';
import 'dart:typed_data';

class Review {
  final String userId;
  final int whereId;
  final String reviewContent;
  final int whereLike;
  final double whereRate;
  final bool reasonMenu;
  final bool reasonMood;
  final bool reasonSafe;
  final bool reasonSeat;
  final bool reasonTransport;
  final bool reasonPark;
  final bool reasonLong;
  final bool reasonView;
  final bool reasonInteraction;
  final bool reasonQuiet;
  final bool reasonPhoto;
  final bool reasonWatch;
  final List<Uint8List?>? reviewImages;

  final String whereName;
  final String whereLocate;
  final double? latitude;
  final double? longitude;

  Review({
    required this.userId,
    required this.whereId,
    required this.reviewContent,
    required this.whereLike,
    required this.whereRate,
    required this.reasonMenu,
    required this.reasonMood,
    required this.reasonSafe,
    required this.reasonSeat,
    required this.reasonTransport,
    required this.reasonPark,
    required this.reasonLong,
    required this.reasonView,
    required this.reasonInteraction,
    required this.reasonQuiet,
    required this.reasonPhoto,
    required this.reasonWatch,
    this.reviewImages,
    required this.whereName,
    required this.whereLocate,
    this.latitude,
    this.longitude,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // 디버그: JSON 데이터 확인
    print('Original JSON Data: $json');

    // 리뷰 이미지 리스트 디코딩
    List<Uint8List?> imageList = [];
    if (json['images'] != null && json['images'] is List) {
      for (var base64Image in json['images']) {
        if (base64Image != null && base64Image is String) {
          try {
            imageList.add(base64Decode(base64Image));
          } catch (e) {
            print('이미지 디코딩 실패: $e');
            imageList.add(null);
          }
        } else {
          imageList.add(null);
        }
      }
    }

    // 각 필드를 수동으로 파싱하여 불리언 값으로 변환
    final review = Review(
      userId: json['user_id'] as String? ?? '',
      whereId: json['where_id'] as int? ?? 0,
      reviewContent: json['review_content'] as String? ?? '',
      whereLike: json['where_like'] as int? ?? 0,
      whereRate: (json['where_rate'] as num?)?.toDouble() ?? 0.0,
      reasonMenu: json['reason_menu'] == true || json['reason_menu'] == 'true' || json['reason_menu'] == 1,
      reasonMood: json['reason_mood'] == true || json['reason_mood'] == 'true' || json['reason_mood'] == 1,
      reasonSafe: json['reason_safe'] == true || json['reason_safe'] == 'true' || json['reason_safe'] == 1,
      reasonSeat: json['reason_seat'] == true || json['reason_seat'] == 'true' || json['reason_seat'] == 1,
      reasonTransport: json['reason_transport'] == true || json['reason_transport'] == 'true' || json['reason_transport'] == 1,
      reasonPark: json['reason_park'] == true || json['reason_park'] == 'true' || json['reason_park'] == 1,
      reasonLong: json['reason_long'] == true || json['reason_long'] == 'true' || json['reason_long'] == 1,
      reasonView: json['reason_view'] == true || json['reason_view'] == 'true' || json['reason_view'] == 1,
      reasonInteraction: json['reason_interaction'] == true || json['reason_interaction'] == 'true' || json['reason_interaction'] == 1,
      reasonQuiet: json['reason_quiet'] == true || json['reason_quiet'] == 'true' || json['reason_quiet'] == 1,
      reasonPhoto: json['reason_photo'] == true || json['reason_photo'] == 'true' || json['reason_photo'] == 1,
      reasonWatch: json['reason_watch'] == true || json['reason_watch'] == 'true' || json['reason_watch'] == 1,
      reviewImages: imageList,
      whereName: json['where_name'] as String? ?? '',
      whereLocate: json['where_locate'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

    // 디버그: 파싱된 리뷰 데이터 확인
    print('Parsed Review Data: '
          'userId=${review.userId}, whereId=${review.whereId}, reviewContent=${review.reviewContent}, '
          'whereLike=${review.whereLike}, whereRate=${review.whereRate}, reasonMenu=${review.reasonMenu}, '
          'reasonMood=${review.reasonMood}, reasonSafe=${review.reasonSafe}, reasonSeat=${review.reasonSeat}, '
          'reasonTransport=${review.reasonTransport}, reasonPark=${review.reasonPark}, reasonLong=${review.reasonLong}, '
          'reasonView=${review.reasonView}, reasonInteraction=${review.reasonInteraction}, reasonQuiet=${review.reasonQuiet}, '
          'reasonPhoto=${review.reasonPhoto}, reasonWatch=${review.reasonWatch}, whereName=${review.whereName}, '
          'whereLocate=${review.whereLocate}, latitude=${review.latitude}, longitude=${review.longitude}, '
          'reviewImages=${review.reviewImages?.length ?? 0}');

    return review;
  }
}
  