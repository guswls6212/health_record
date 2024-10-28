import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../database/dao/workout_record_dao.dart';
import 'exercise.dart';
import 'workout_set.dart'; // WorkoutSet import 추가

class WorkoutRecord {
  final String id;
  final Exercise exercise;
  final DateTime date;
  final List<WorkoutSet> sets; // WorkoutSet 객체 리스트로 변경
  int? syncStatus;

  WorkoutRecord({
    required this.id,
    required this.exercise,
    required this.date,
    required this.sets,
    this.syncStatus,
  });

  factory WorkoutRecord.fromMap(Map<String, dynamic> map) {
    // map['sets']는 List<WorkoutSet>으로 변환되어야 함
    final sets = (map['sets'] as List<dynamic>)
        .map((set) => WorkoutSet.fromMap(set as Map<String, dynamic>))
        .toList();

    return WorkoutRecord(
      id: map[DatabaseHelper.columnId] as String,
      exercise: Exercise.fromMap(
          map[DatabaseHelper.columnExerciseId] as Map<String, dynamic>),
      date: DateTime.parse(map[DatabaseHelper.columnDate] as String),
      sets: sets, // 변환된 sets 사용
      syncStatus: map[DatabaseHelper.columnSyncStatus] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    // sets를 Map<String, dynamic>의 List로 변환
    final setsList = sets.map((set) => set.toMap()).toList();

    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnExerciseId: exercise.toMap(),
      DatabaseHelper.columnDate: date.toIso8601String(),
      DatabaseHelper.columnSets: setsList, // 변환된 setsList 사용
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
