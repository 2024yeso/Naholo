// lib/models/review.dart

class Review {
  final String whereName;
  final String whereLocate;
  final String reviewContent;
  final double whereRate;
  final String reviewImage;

  Review({
    required this.whereName,
    required this.whereLocate,
    required this.reviewContent,
    required this.whereRate,
    required this.reviewImage,
  });

  // JSON 데이터를 Review 객체로 변환
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      whereName: json['WHERE_NAME'],
      whereLocate: json['WHERE_LOCATE'],
      reviewContent: json['REVIEW_CONTENT'],
      whereRate: json['WHERE_RATE'].toDouble(),
      reviewImage: json['REVIEW_IMAGE'] ?? '',
    );
  }
}
