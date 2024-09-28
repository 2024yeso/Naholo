import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_day_data.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:nahollo/screens/main_screen.dart';

class AttendMainScreen extends StatefulWidget {
  final bool hasCheckedInToday; // 오늘 출석 체크 여부 전달 받음

  const AttendMainScreen({super.key, required this.hasCheckedInToday});

  @override
  State<AttendMainScreen> createState() => _AttendMainScreenState();
}

class _AttendMainScreenState extends State<AttendMainScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출석체크'),
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeScaler.scaleSize(context, 2)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TableCalendar(
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
                  // 오늘 날짜 셀 생성 (오늘 날짜도 출석 체크된 날짜와 동일하게 표기)
                  todayBuilder: (context, day, focusedDay) {
                    if (attendanceDays.any(
                        (attendanceDay) => isSameDay(attendanceDay, day))) {
                      return _buildDay(day, const Color(0xff794FFF),
                          const Color.fromARGB(255, 0, 0, 0));
                    } else {
                      return _buildDay(day, Colors.grey.shade200, Colors.black);
                    }
                  },
                  // 선택된 날짜 셀 생성
                  selectedBuilder: (context, day, focusedDay) {
                    return _buildDay(day, const Color(0xff794FFF),
                        const Color.fromARGB(255, 0, 0, 0));
                  },
                  // 출석 체크된 날짜 셀 생성
                  markerBuilder: (context, day, events) {
                    if (attendanceDays.any(
                        (attendanceDay) => isSameDay(attendanceDay, day))) {
                      return _buildDay(day, const Color(0xff794FFF),
                          const Color.fromARGB(255, 0, 0, 0));
                    }
                    return null;
                  },
                  dowBuilder: (context, day) {
                    // 요일 표시 커스터마이징 (월, 화, 수, ...)
                    final daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 0), // 요일에 패딩 추가
                      child: Center(
                        child: Text(
                          daysOfWeek[day.weekday - 1],
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
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
                  headerPadding: const EdgeInsets.only(
                      left: 1.0, bottom: 1.0), // 왼쪽으로 패딩 조정
                  titleTextStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                  titleCentered: false, // 년 월이 왼쪽 상단에 표시되도록 설정
                  formatButtonVisible: false,

                  titleTextFormatter: (date, locale) =>
                      DateFormat.yMMMM(locale).format(date), // 년 월 표시 형식
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, // 그라데이션 시작 위치
                    end: Alignment.bottomRight, // 그라데이션 끝 위치 )
                    colors: [
                      Color(0xffC27EF7), // 보라색
                      Color(0xff9d93ff),
                      Color(0xffa0a3f5),
                    ],
                  ),
                ),
                height: SizeScaler.scaleSize(context, 255),
                width: SizeScaler.scaleSize(context, 197),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: SizeScaler.scaleSize(context, 8),
                    top: SizeScaler.scaleSize(context, 8),
                  ),
                  child: Text(
                    "오늘의 출첵 보상",
                    style: TextStyle(
                      fontSize: SizeScaler.scaleSize(
                        context,
                        12,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 날짜 셀을 생성하는 함수
  Widget _buildDay(DateTime day, Color backgroundColor, Color textColor) {
    return Column(
      children: [
        Text(
          '${day.day}',
          style: TextStyle(color: textColor),
        ),
        Padding(
          padding: EdgeInsets.all(
            SizeScaler.scaleSize(context, 3),
          ),
          child: Container(
            width: SizeScaler.scaleSize(context, 10), // 원의 크기 조정
            height: SizeScaler.scaleSize(context, 10), // 원의 크기 조정
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
