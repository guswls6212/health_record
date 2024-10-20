import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'exercise/exercise.dart';

class WorkoutRecord {
  final String id;
  final String exerciseId;
  final DateTime date;
  final List<Map<String, dynamic>> sets;

  WorkoutRecord({
    required this.id,
    required this.exerciseId,
    required this.date,
    required this.sets,
  });

  factory WorkoutRecord.fromMap(Map<String, dynamic> map) {
    return WorkoutRecord(
      id: map['id'] as String,
      exerciseId: map['exerciseId'] as String,
      date: DateTime.parse(map['date'] as String),
      sets: (map['sets'] as List<dynamic>)
          .map((set) => set as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'date': date.toIso8601String(),
      'sets': sets,
    };
  }
}

class WorkoutRecordModel extends ChangeNotifier {
  List<WorkoutRecord> _workoutRecords = [];

  List<WorkoutRecord> get workoutRecords => _workoutRecords;

  Future<void> loadWorkoutRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutRecordList = prefs.getStringList('workoutRecords') ?? [];
    _workoutRecords = workoutRecordList
        .map((workoutRecordJson) => WorkoutRecord.fromMap(
            Map<String, dynamic>.from(jsonDecode(workoutRecordJson))))
        .toList();
    notifyListeners();
  }

  Future<void> _saveWorkoutRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutRecordList = _workoutRecords
        .map((workoutRecord) => jsonEncode(workoutRecord.toMap()))
        .toList();
    await prefs.setStringList('workoutRecords', workoutRecordList);
  }

  void addWorkoutRecord(WorkoutRecord record) {
    _workoutRecords.add(record);
    _saveWorkoutRecords();
    notifyListeners();
  }

  void editWorkoutRecord(WorkoutRecord record) {
    final index = _workoutRecords.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _workoutRecords[index] = record;
      _saveWorkoutRecords();
      notifyListeners();
    }
  }

  void deleteWorkoutRecord(String id) {
    _workoutRecords.removeWhere((r) => r.id == id);
    _saveWorkoutRecords();
    notifyListeners();
  }

  List<WorkoutRecord> getWorkoutRecordsByDate(DateTime date) {
    return _workoutRecords
        .where((r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day)
        .toList();
  }
}
