// 데이터베이스에서 불러온 int 리스트를 DateTime으로 변환
Map<String, List<int>> receiveDayData = {
  'attendanceDays': [
    1717248000000,
    1717334400000,
    1717420800000,
    1717593600000,
    1717852800000
  ]
};
List<int> timestamps = receiveDayData['attendanceDays']!;
List<DateTime> convertedDates =
    timestamps.map((ts) => DateTime.fromMillisecondsSinceEpoch(ts)).toList();

List<DateTime> attendanceDays = [
  DateTime(2024, 6, 1),
  DateTime(2024, 6, 2),
  DateTime(2024, 6, 3),
  DateTime(2024, 6, 5),
  DateTime(2024, 6, 8),
]; // 출석체크된 날짜들 예시

// DateTime 리스트를 int 리스트로 변환하여 Map에 저장
Map<String, List<int>> sendDayData = {
  'attendanceDays':
      attendanceDays.map((date) => date.millisecondsSinceEpoch).toList(),
};
//출력예시 { 'attendanceDays': [1717248000000, 1717334400000, 1717420800000, 1717593600000, 1717852800000] }



