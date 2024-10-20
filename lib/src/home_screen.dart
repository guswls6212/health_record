// home_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercise/exercise.dart';
import 'workout_record.dart';
import 'workout_record_detail_screen.dart'; // 추가

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WorkoutRecordModel>(context, listen: false)
        .loadWorkoutRecords();
  }

  Future<void> changeSharedPreferenceValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final workoutRecordList = prefs.getStringList('workoutRecords') ?? [];
    List<Map<String, dynamic>> workoutRecords = workoutRecordList
        .map((workoutRecordJson) =>
            Map<String, dynamic>.from(jsonDecode(workoutRecordJson)))
        .toList();

// 예시: 모든 운동 기록의 exerciseId를 'newExerciseId'로 변경
    for (var record in workoutRecords) {
      record['exerciseId'] = '1';
    }

    final updatedWorkoutRecordList = workoutRecords
        .map((workoutRecord) => jsonEncode(workoutRecord))
        .toList();
    await prefs.setStringList('workoutRecords', updatedWorkoutRecordList);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkoutRecordModel, ExerciseModel>(
      builder: (context, workoutRecordModel, exerciseModel, child) {
        return ListView.builder(
          itemCount: workoutRecordModel.workoutRecords.length,
          itemBuilder: (context, index) {
            final record = workoutRecordModel.workoutRecords[index];
            // changeSharedPreferenceValue();
            final exercise = exerciseModel.getExerciseById(record.exerciseId);
            if (exercise!.id == '') {
              // 일치하는 운동이 없는 경우
              return const Center(child: Text('No data'));
            }
            return Card(
              child: ListTile(
                leading: Icon(Icons.fitness_center),
                // Image.asset('images/add_health_image.jpeg'),
                // 이미지 파일 경로
                title: Text(exercise.name),
                subtitle: Text(
                    '${DateFormat('yyyy-MM-dd').format(record.date)} - ${record.sets.length}세트'),
                onTap: () {
                  // 운동 기록 상세 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutRecordDetailScreen(
                        workoutRecord: record,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
