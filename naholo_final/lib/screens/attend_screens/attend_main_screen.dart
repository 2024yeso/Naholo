import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AttendMainScreen extends StatefulWidget {
  final bool hasCheckedInToday; // 오늘 출석 체크 여부 전달 받음

  const AttendMainScreen({super.key, required this.hasCheckedInToday});

  @override
  State<AttendMainScreen> createState() => _AttendMainScreenState();
}

class _AttendMainScreenState extends State<AttendMainScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<DateTime> _attendanceDays = [
    DateTime(2024, 6, 1),
    DateTime(2024, 6, 2),
    DateTime(2024, 6, 3),
    DateTime(2024, 6, 5),
    DateTime(2024, 6, 8),
  ]; // 출석체크된 날짜들 예시

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출석체크'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          locale: 'ko_KR', // 한국어로 표시 설정
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => _selectedDay == day,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarBuilders: CalendarBuilders(
            // 기본 날짜 셀 생성
            defaultBuilder: (context, day, focusedDay) {
              return _buildDay(day, Colors.grey.shade200, Colors.black);
            },
            // 선택된 날짜 셀 생성
            selectedBuilder: (context, day, focusedDay) {
              return _buildDay(
                  day, Colors.purple, const Color.fromARGB(255, 0, 0, 0));
            },
            // 출석 체크된 날짜 셀 생성
            markerBuilder: (context, day, events) {
              if (_attendanceDays
                  .any((attendanceDay) => isSameDay(attendanceDay, day))) {
                return _buildDay(day, const Color(0xff794FFF),
                    const Color.fromARGB(255, 0, 0, 0));
              }
              return null;
            },
            dowBuilder: (context, day) {
              // 요일 표시 커스터마이징 (월, 화, 수, ...)
              final daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 0), // 요일에 패딩 추가
                child: Center(
                  child: Text(
                    daysOfWeek[day.weekday - 1],
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
              );
            },
          ),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            isTodayHighlighted: true,
            markersAlignment: Alignment.center, // 마커를 가운데로 정렬
          ),
          headerStyle: HeaderStyle(
            headerPadding:
                const EdgeInsets.only(left: 1.0, bottom: 1.0), // 왼쪽으로 패딩 조정
            titleTextStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            titleCentered: false, // 년 월이 왼쪽 상단에 표시되도록 설정
            formatButtonVisible: false,

            titleTextFormatter: (date, locale) =>
                DateFormat.yMMMM(locale).format(date), // 년 월 표시 형식
          ),
        ),
      ),
    );
  }

  // 날짜 셀을 생성하는 함수
  Widget _buildDay(DateTime day, Color backgroundColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(4.0), // 원 사이의 간격 추가
      child: Column(
        children: [
          Text(
            '${day.day}',
            style: TextStyle(color: textColor),
          ),
          Container(
            width: 20, // 원의 크기 조정
            height: 20,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
