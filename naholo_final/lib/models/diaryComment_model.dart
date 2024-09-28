// diaryComment_model.dart

class diaryComment_model {
  final int comment_id;
  final int post_id;
  final String user_id;
  final String author;
  final String content;
  final String created_at;

  diaryComment_model({
    required this.comment_id,
    required this.post_id,
    required this.user_id,
    required this.author,
    required this.content,
    required this.created_at,
  });

  factory diaryComment_model.fromJson(Map<String, dynamic> json) {
    return diaryComment_model(
      comment_id: json['comment_id'],
      post_id: json['post_id'],
      user_id: json['user_id'],
      author: json['author'],
      content: json['content'],
      created_at: json['created_at'],
    );
  }
}
