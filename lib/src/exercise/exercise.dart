import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart'; // DatabaseHelper import
import '../database/dao/exercise_dao.dart';

class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final bool isDefault;
  int? syncStatus;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    this.isDefault = false,
    this.syncStatus,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map[DatabaseHelper.columnId] as String, // DB 컬럼명으로 변경
      name: map[DatabaseHelper.columnName] as String, // DB 컬럼명으로 변경
      bodyPart: map[DatabaseHelper.columnBodyPart] as String, // DB 컬럼명으로 변경
      isDefault: map[DatabaseHelper.columnIsDefault] == 1,
      syncStatus: map[DatabaseHelper.columnSyncStatus] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id, // DB 컬럼명으로 변경
      DatabaseHelper.columnName: name, // DB 컬럼명으로 변경
      DatabaseHelper.columnBodyPart: bodyPart, // DB 컬럼명으로 변경
      DatabaseHelper.columnIsDefault: isDefault ? 1 : 0,
      DatabaseHelper.columnSyncStatus: syncStatus,
    };
  }
}

class ExerciseModel extends ChangeNotifier {
  final ExerciseDao _exerciseDao = ExerciseDao();
  List<Exercise> _exercises = [];

  List<Exercise> get exercises => _exercises;

  final List<Exercise> _defaultExercises = [
    Exercise(id: '1', name: '벤치프레스', bodyPart: '가슴', isDefault: true),
    Exercise(id: '2', name: '스쿼트', bodyPart: '하체', isDefault: true),
  ];

  Future<void> loadExercises() async {
    _exercises = await _exerciseDao.getExercises();

    // _defaultExercises에 있는 운동이 _exercises에 없으면 추가
    for (var defaultExercise in _defaultExercises) {
      if (!_exercises.any((e) => e.id == defaultExercise.id)) {
        _exercises.add(defaultExercise);
        await _exerciseDao.insertExercise(defaultExercise); // SQLite에 저장
      }
    }

    notifyListeners();
  }

  void addExercise(Exercise exercise) async {
    await _exerciseDao.insertExercise(exercise);
    _exercises.add(exercise);
    notifyListeners();
  }

  void editExercise(Exercise exercise) async {
    await _exerciseDao.updateExercise(exercise);
    final index = _exercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      _exercises[index] = exercise;
      notifyListeners();
    }
  }

  void deleteExercise(String id) async {
    await _exerciseDao.deleteExercise(id);
    _exercises.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Exercise? getExerciseById(String id) {
    return _exercises.firstWhereOrNull((e) => e.id == id);
  }

  Future<void> syncExercises(String userEmail) async {
    final List<Exercise> exercisesToSync =
        await _exerciseDao.getExercisesToSync(userEmail);

    // TODO: 클라우드에 exercisesToSync 업로드

    // 업로드 성공 시 sync_status 업데이트
    for (var exercise in exercisesToSync) {
      exercise.syncStatus = 1;
      await _exerciseDao.updateExercise(exercise);
    }

    notifyListeners();
  }
}
