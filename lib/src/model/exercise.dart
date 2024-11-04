import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../database/dao/exercise_dao.dart';
import 'body_part.dart';
import '../database/database_helper.dart';

class Exercise {
  final String name;
  final BodyPart bodyPart;
  final bool isDefault;
  int? syncStatus;
  int sortOrder; // sortOrder 필드 추가

  Exercise({
    required this.name,
    required this.bodyPart,
    this.isDefault = false,
    this.syncStatus,
    this.sortOrder = 0, // sortOrder 필드 추가
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map[DatabaseHelper.columnName] as String,
      bodyPart:
          BodyPart(name: map[DatabaseHelper.columnBodyPartName] as String),
      isDefault: map[DatabaseHelper.columnIsDefault] == 1,
      syncStatus: map[DatabaseHelper.columnSyncStatus] as int?,
      sortOrder: map[DatabaseHelper.columnSortOrder] as int, // sortOrder 필드 추가
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnBodyPartName: bodyPart.name,
      DatabaseHelper.columnIsDefault: isDefault ? 1 : 0,
      DatabaseHelper.columnSyncStatus: syncStatus,
      DatabaseHelper.columnSortOrder: sortOrder, // sortOrder 필드 추가
    };
  }

  Exercise copyWith({
    String? name,
    BodyPart? bodyPart,
    bool? isDefault,
    int? syncStatus,
    int? sortOrder,
  }) {
    return Exercise(
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      isDefault: isDefault ?? this.isDefault,
      syncStatus: syncStatus ?? this.syncStatus,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class ExerciseModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late ExerciseDao _exerciseDao;

  ExerciseModel() {
    _exerciseDao = ExerciseDao(_databaseHelper);
  }

  List<Exercise> _exercises = [];

  List<Exercise> get exercises => _exercises;

  Future<void> loadExercises() async {
    _exercises = await _exerciseDao.getExercises();
    notifyListeners();
  }

  void addExercise(Exercise exercise) async {
    await _exerciseDao.insertExercise(exercise);
    _exercises.add(exercise);
    notifyListeners();
  }

  void editExercise(Exercise originalExercise, Exercise editedExercise) async {
    // originalExercise 추가
    await _exerciseDao.updateExercise(
        originalExercise, editedExercise); // ExerciseDao의 updateExercise 메서드 수정
    final index = _exercises
        .indexWhere((e) => e.name == originalExercise.name); // 원래 이름으로 검색
    if (index != -1) {
      _exercises[index] = editedExercise;
      notifyListeners();
    }
  }

  void deleteExercise(String name) async {
    // id 대신 name 사용
    await _exerciseDao.deleteExercise(name); // id 대신 name 사용
    _exercises.removeWhere((e) => e.name == name); // id 대신 name 사용
    notifyListeners();
  }

  Exercise? getExerciseByName(String name) {
    // id 대신 name 사용
    return _exercises.firstWhereOrNull((e) => e.name == name); // id 대신 name 사용
  }

  List<Exercise> getExercisesByBodyPart(String bodyPartName) {
    return _exercises
        .where((exercise) => exercise.bodyPart.name == bodyPartName)
        .toList();
  }

  Future<int> getNextSortOrder(String bodyPartName) async {
    final exercises = getExercisesByBodyPart(bodyPartName);
    if (exercises.isEmpty) {
      return 1;
    } else {
      return exercises.map((e) => e.sortOrder).reduce(max) + 1;
    }
  }
}
