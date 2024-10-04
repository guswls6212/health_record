import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위한 패키지

class StepCalendar extends StatefulWidget {
  @override
  _StepCalendarState createState() => _StepCalendarState();
}

class _StepCalendarState extends State<StepCalendar> {
  DateTime _selectedDate = DateTime.now();

  List<DateTime> getDaysInMonth(DateTime month) {
    // 해당 월의 첫째 날 요일 구하기 (월요일: 1, 일요일: 7)
    var firstDayOfMonth = DateTime(month.year, month.month, 1);
    var firstDayOfWeek = firstDayOfMonth.weekday;

    // 해당 월의 마지막 날 구하기
    var lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    var numberOfDaysInMonth = lastDayOfMonth.day;

    // 날짜와 요일 정보를 포함하는 리스트 생성
    List<DateTime> days = [];
    for (var i = 1 - firstDayOfWeek; i <= numberOfDaysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i + firstDayOfWeek - 1));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StepCalendar')),
      body: Column(
        children: [
          // 년월 표시 행
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                        _selectedDate.year, _selectedDate.month - 1, 1);

                    _buildDays();
                  });
                },
              ),
              Text(DateFormat('yyyy년 MM월').format(_selectedDate)),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                        _selectedDate.year, _selectedDate.month + 1, 1);
                    _buildDays();
                  });
                },
              ),
            ],
          ),
          // 요일 표시 행
          Row(
            children: [
              for (var day in ['월', '화', '수', '목', '금', '토', '일'])
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey[200],
                    child: Text(day),
                  ),
                ),
            ],
          ),
          // 날짜 표시 GridView
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              children: _buildDays(),
            ),
          ),
        ],
      ),
    );
  }

  List<GestureDetector> _buildDays() {
    print(_selectedDate);
    List<DateTime> days = getDaysInMonth(_selectedDate); // 선택된 날짜 기준으로 달력 생성

    return days.map((day) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = day;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _selectedDate == day ? Colors.blue : Colors.white,
            border: Border.all(color: Colors.grey),
          ),
          child: Text('${day.day}'),
        ),
      );
    }).toList();
  }
}
