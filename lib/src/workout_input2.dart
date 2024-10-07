import 'package:flutter/material.dart';

class ExerciseSetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 뒤로 가기 기능 구현
          },
        ),
        title: Text('세트'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              // 완료 버튼 기능 구현
            },
          ),
        ],
      ),
      body: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Image.asset('assets/images/bench_press.png'),
              Text('벤치 프레스 · 스미스 머신'),
              Text('1/3 완료'),
              CheckboxListTile(
                title: Text('1. 30KG 12회'),
                value: true, // 초기값 설정
                onChanged: (value) {
                  // 체크박스 변경 시 처리 로직
                },
              ),
              // ... 다른 세트 정보
              ElevatedButton(
                onPressed: () {
                  // 세트 추가 기능 구현
                },
                child: Text('+ 세트 추가'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 운동 추가 기능 구현
                },
                child: Text('+ 운동 추가'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
