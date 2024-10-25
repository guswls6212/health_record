import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'exercise/exercise.dart';
import './database/database_helper.dart'; // DatabaseHelper import
import './database/dao/workout_record_dao.dart';

class WorkoutRecord {
  final String id;
  final String exerciseId;
  final DateTime date;
  final List<Map<String, dynamic>> sets;
  int? syncStatus;

  WorkoutRecord({
    required this.id,
    required this.exerciseId,
    required this.date,
    required this.sets,
    this.syncStatus,
  });

  factory WorkoutRecord.fromMap(Map<String, dynamic> map) {
    return WorkoutRecord(
      id: map[DatabaseHelper.columnId] as String, // DB 컬럼명으로 변경
      exerciseId: map[DatabaseHelper.columnExerciseId] as String, // DB 컬럼명으로 변경
      date: DateTime.parse(
          map[DatabaseHelper.columnDate] as String), // DB 컬럼명으로 변경
      sets: (jsonDecode(map[DatabaseHelper.columnSets] as String)
              as List<dynamic>)
          .map((set) => set as Map<String, dynamic>)
          .toList(),
      syncStatus: map[DatabaseHelper.columnSyncStatus] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id, // DB 컬럼명으로 변경
      DatabaseHelper.columnExerciseId: exerciseId, // DB 컬럼명으로 변경
      DatabaseHelper.columnDate: date.toIso8601String(), // DB 컬럼명으로 변경
      DatabaseHelper.columnSets: jsonEncode(sets),
      DatabaseHelper.columnSyncStatus: syncStatus,
    };
  }
}

class WorkoutRecordModel extends ChangeNotifier {
  final WorkoutRecordDao _workoutRecordDao = WorkoutRecordDao();
  List<WorkoutRecord> _workoutRecords = [];

  List<WorkoutRecord> get workoutRecords => _workoutRecords;

  Future<void> loadWorkoutRecords() async {
    _workoutRecords = await _workoutRecordDao.getWorkoutRecords();
    notifyListeners();
  }

  void addWorkoutRecord(WorkoutRecord record) async {
    await _workoutRecordDao.insertWorkoutRecord(record);
    _workoutRecords.add(record);
    notifyListeners();
  }

  void editWorkoutRecord(WorkoutRecord record) async {
    await _workoutRecordDao.updateWorkoutRecord(record);
    final index = _workoutRecords.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _workoutRecords[index] = record;
      notifyListeners();
    }
  }

  void deleteWorkoutRecord(String id) async {
    await _workoutRecordDao.deleteWorkoutRecord(id);
    _workoutRecords.removeWhere((r) => r.id == id);
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

  Future<void> syncWorkoutRecords(String userEmail) async {
    final List<WorkoutRecord> recordsToSync =
        await _workoutRecordDao.getWorkoutRecordsToSync(userEmail);

    // TODO: 클라우드에 recordsToSync 업로드

    // 업로드 성공 시 sync_status 업데이트
    for (var record in recordsToSync) {
      record.syncStatus = 1;
      await _workoutRecordDao.updateWorkoutRecord(record);
    }

    notifyListeners();
  }
}
