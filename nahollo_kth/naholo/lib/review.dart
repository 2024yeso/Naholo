// lib/models/review.dart

class Review {
  final String whereName;
  final String whereLocate;
  final String reviewContent;
  final double whereRate;
  final String? reviewImage;
  final double? latitude;
  final double? longitude;

  Review({
    required this.whereName,
    required this.whereLocate,
    required this.reviewContent,
    required this.whereRate,
    this.reviewImage,
    this.latitude,
    this.longitude,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      whereName: json['WHERE_NAME'],
      whereLocate: json['WHERE_LOCATE'],
      reviewContent: json['REVIEW_CONTENT'],
      whereRate: (json['WHERE_RATE'] as num).toDouble(),
      reviewImage: json['REVIEW_IMAGE'],
      latitude: json['LATITUDE'] != null ? (json['LATITUDE'] as num).toDouble() : null,
      longitude: json['LONGITUDE'] != null ? (json['LONGITUDE'] as num).toDouble() : null,
    );
  }
}
