// diaryComment_model.dart
  class diaryComment_model {
  final String author; // 댓글 작성자 이름
  final String authorID; // 댓글 작성자 ID
  final String content; // 댓글 내용
  final int postId;

  diaryComment_model({
    required this.postId,
    required this.author,
    required this.authorID,
    required this.content,
  });
}
