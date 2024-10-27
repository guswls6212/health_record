import 'package:flutter/material.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({Key? key}) : super(key: key);

  @override
  _AddWorkoutScreenState createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 운동 종류 드롭다운
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '운동 종류'),
              items: <String>['가슴', '등', '하체', '어깨', '팔']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // TODO: 선택된 운동 종류 처리
              },
            ),
            const SizedBox(height: 16.0),
            // 운동 이름 입력 필드
            TextFormField(
              decoration: const InputDecoration(labelText: '운동 이름'),
            ),
            const SizedBox(height: 16.0),
            // 메모 내용 입력 필드
            TextFormField(
              decoration: const InputDecoration(labelText: '메모 내용'),
              maxLines: 5,
            ),
            const Spacer(),
            // 저장 버튼
            ElevatedButton(
              onPressed: () {
                // TODO: 운동 정보 저장
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
