// workout_record.dart
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../database/dao/workout_record_dao.dart';
import 'exercise.dart';
import 'workout_set.dart';

class WorkoutRecord {
  final String id;
  final String exerciseName; // Exercise 객체 대신 exerciseName 사용
  final DateTime date;
  final List<WorkoutSet> sets;
  int? syncStatus;

  WorkoutRecord({
    required this.id,
    required this.exerciseName, // exerciseName 필드 추가
    required this.date,
    required this.sets,
    this.syncStatus,
  });

  factory WorkoutRecord.fromMap(Map<String, dynamic> map) {
    final sets = (map['sets'] as List<dynamic>)
        .map((set) => WorkoutSet.fromMap(set as Map<String, dynamic>))
        .toList();

    return WorkoutRecord(
      id: map[DatabaseHelper.columnId] as String,
      exerciseName:
          map[DatabaseHelper.columnExerciseName] as String, // exerciseName 읽어오기
      date: DateTime.parse(map[DatabaseHelper.columnDate] as String),
      sets: sets,
      syncStatus: map[DatabaseHelper.columnSyncStatus] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnExerciseName: exerciseName, // exerciseName 저장
      DatabaseHelper.columnDate: date.toIso8601String(),
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
