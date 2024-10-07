import 'package:flutter/material.dart';

class WorkoutRecordInput extends StatefulWidget {
  @override
  _WorkoutRecordInputState createState() => _WorkoutRecordInputState();
}

class _WorkoutRecordInputState extends State<WorkoutRecordInput> {
  final TextEditingController _setController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _rmController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSpotted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 세트 번호
            TextField(
              controller: _setController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Set',
              ),
            ),
            // 무게
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight',
                    ),
                  ),
                ),
                Text('kg'),
              ],
            ),
            // 반복 횟수
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Reps',
                    ),
                  ),
                ),
                Text('R'),
              ],
            ),
            // 최대 반복 무게
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rmController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'RM',
                    ),
                  ),
                ),
                Text('kg'),
              ],
            ),
            // 스팟팅 여부
            Row(
              children: [
                Text('Spotting'),
                Checkbox(
                  value: _isSpotted,
                  onChanged: (value) {
                    setState(() {
                      _isSpotted = value!;
                    });
                  },
                ),
              ],
            ),
            // 추가 메모
            TextField(
              controller: _notesController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Notes',
              ),
            ),
            // 저장 버튼 등 추가적인 기능 구현
          ],
        ),
      ),
    );
  }
}
