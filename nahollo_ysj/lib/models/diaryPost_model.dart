// diaryPost_model.dart
class diaryPost_model {
  final String author; // 일지 작성자 이름
  final String authorID; // 일지 작성자
  final DateTime createdAt; // 일지 작성 시간
  final String title; // 일지 제목
  final String content; // 일지 내용
  final int likes; // 일지 좋아요 수
  final bool liked; // 유저의 일지 좋아요 여부

  diaryPost_model({
    required this.author,
    required this.authorID,
    required this.createdAt,
    required this.title,
    required this.content,
    required this.likes,
    required this.liked,
  });

  String getContentPreview(int length) {
    // 본문 미리보기용 문자열을 생성
    return content.length > length ? '${content.substring(0, length)}...' : content;
  }
}
