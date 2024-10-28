// workout_record_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/workout_record.dart';

class WorkoutRecordDetailScreen extends StatelessWidget {
  final WorkoutRecord workoutRecord;

  const WorkoutRecordDetailScreen({Key? key, required this.workoutRecord})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 기록 상세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운동 이름: ${workoutRecord.exercise.name}', // exercise.name으로 변경
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8.0),
            Text(
              '운동 부위: ${workoutRecord.exercise.bodyPart.name}', // exercise.bodyPart.name으로 변경
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8.0),
            Text(
              '날짜: ${DateFormat('yyyy-MM-dd').format(workoutRecord.date)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '세트 정보',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: workoutRecord.sets.length,
                itemBuilder: (context, index) {
                  final set = workoutRecord.sets[index];
                  return ListTile(
                    title: Text(
                      '${index + 1}세트: ${set.weight}kg x ${set.reps}회, ${set.duration}초', // set.weight, set.reps, set.duration 사용
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
