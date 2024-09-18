// diaryclass_Diarypostlist.dart
class DiaryPostList {
  final String author; // 일지 작성자
  final DateTime createdAt; // 일지 작성 시간
  final String title; // 일지 제목
  final String content; // 일지 내용
  final int hot; // 일지 좋아요 수
  final bool subscribe; // 유저의 일지 구독 여부
  final bool hotted; // 유저의 일지 좋아요 여부
  final bool ghosted; // 유저의 작성자 차단 여부

  DiaryPostList({
    required this.author,
    required this.createdAt,
    required this.title,
    required this.content,
    required this.hot,
    required this.subscribe,
    this.hotted = false,
    this.ghosted = false,
  });

  String getContentPreview(int length) {
    // 본문 미리보기용 문자열을 생성
    return content.length > length ? '${content.substring(0, length)}...' : content;
  }
}
