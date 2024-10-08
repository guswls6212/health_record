import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseSetScreen extends StatefulWidget {
  @override
  State<ExerciseSetScreen> createState() => _ExerciseSetScreenState();
}

class _ExerciseSetScreenState extends State<ExerciseSetScreen> {
  bool _isChecked = false;
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
      body: ListView(children: [
        Column(children: [
          IntrinsicHeight(
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('벤치 프레스 · 스미스 머신'),
                    Text('1/3 완료'),
                    Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 64,
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                '1',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Container(
                              width: 64,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                ),
                              )),
                          // Container(child: Text('KG')),
                          // TextField(),
                          // Text('회'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Card(
              color: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    CheckboxListTile(
                      title: Text('1. 30KG 12회'),
                      value: false, // 초기값 설정
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
                  ]))),
        ]),
      ]),
    );
  }
}
