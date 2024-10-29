import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../database/dao/exercise_dao.dart';
import 'body_part.dart';
import '../database/database_helper.dart';

class Exercise {
  final String id;
  final String name;
  final BodyPart bodyPart;
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
      id: map[DatabaseHelper.columnId] as String,
      name: map[DatabaseHelper.columnName] as String,
      bodyPart: BodyPart(
          name:
              map[DatabaseHelper.columnBodyPartId] as String), // BodyPart 객체 생성
      isDefault: map[DatabaseHelper.columnIsDefault] == 1,
      syncStatus: map[DatabaseHelper.columnSyncStatus] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnBodyPartId: bodyPart.name, // bodyPart.name으로 변경
      DatabaseHelper.columnIsDefault: isDefault ? 1 : 0,
      DatabaseHelper.columnSyncStatus: syncStatus,
    };
  }
}

class ExerciseModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper =
      DatabaseHelper(); // DatabaseHelper 객체 생성
  late ExerciseDao _exerciseDao; // ExerciseDao 객체 생성

  ExerciseModel() {
    _exerciseDao =
        ExerciseDao(_databaseHelper); // ExerciseDao에 DatabaseHelper 객체 전달
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

  List<Exercise> getExercisesByBodyPart(String bodyPartName) {
    return _exercises
        .where((exercise) => exercise.bodyPart.name == bodyPartName)
        .toList();
  }
}
