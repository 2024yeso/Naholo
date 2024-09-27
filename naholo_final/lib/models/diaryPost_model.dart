class diaryPost_model {
  final String author;
  final String authorID;
  final DateTime createdAt;
  final String title;
  final String content;
  final int likes;
  final bool liked;
  final List<bool> subjList;
  final List<dynamic> images; // 이미지 리스트 추가

  diaryPost_model({
    required this.author,
    required this.authorID,
    required this.createdAt,
    required this.title,
    required this.content,
    required this.likes,
    required this.liked,
    required this.subjList,
    required this.images,
  });

  // 본문 미리보기 생성 메서드
  String getContentPreview(int maxLength) {
    if (content.length <= maxLength) {
      return content;
    } else {
      return '${content.substring(0, maxLength)}...';
    }
  }
}
