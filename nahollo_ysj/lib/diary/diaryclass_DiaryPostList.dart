// diaryclass_Diarypostlist.dart
class DiaryPostList {
  final String author;
  final DateTime createdAt;
  final String title;
  final String content;
  final int hot;
  final bool subscribe;

  DiaryPostList({
    required this.author,
    required this.createdAt,
    required this.title,
    required this.content,
    required this.hot,
    required this.subscribe,
  });

  String getContentPreview(int length) {
    // 본문 미리보기용 문자열을 생성
    return content.length > length ? '${content.substring(0, length)}...' : content;
  }
}
