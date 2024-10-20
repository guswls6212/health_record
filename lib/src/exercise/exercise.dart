import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final bool isDefault;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    this.isDefault = false,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      bodyPart: map['bodyPart'] as String,
      isDefault: map['isDefault'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'isDefault': isDefault,
    };
  }
}

class ExerciseModel extends ChangeNotifier {
  List<Exercise> _exercises = [];

  List<Exercise> get exercises => _exercises;

  final List<Exercise> _defaultExercises = [
    Exercise(id: '1', name: '벤치프레스', bodyPart: '가슴', isDefault: true),
    Exercise(id: '2', name: '스쿼트', bodyPart: '하체', isDefault: true),
  ];

  Future<void> loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final exerciseList = prefs.getStringList('userExercises') ?? [];
    _exercises = exerciseList
        .map((exerciseJson) => Exercise.fromMap(
            Map<String, dynamic>.from(jsonDecode(exerciseJson))))
        .toList();

    for (var defaultExercise in _defaultExercises) {
      if (!_exercises.any((e) => e.id == defaultExercise.id)) {
        _exercises.add(defaultExercise);
      }
    }

    notifyListeners();
  }

  Future<void> _saveExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final exerciseList = _exercises
        .where((exercise) => !exercise.isDefault)
        .map((exercise) => jsonEncode(exercise.toMap()))
        .toList();
    await prefs.setStringList('userExercises', exerciseList);
  }

  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
    _saveExercises();
    notifyListeners();
  }

  void editExercise(Exercise exercise) {
    final index = _exercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      _exercises[index] = exercise;
      _saveExercises();
      notifyListeners();
    }
  }

  void deleteExercise(String id) {
    _exercises.removeWhere((e) => e.id == id);
    _saveExercises();
    notifyListeners();
  }

  Exercise? getExerciseById(String id) {
    return _exercises.firstWhere(
      (e) => e.id == id,
      orElse: () =>
          Exercise(id: '', name: '', bodyPart: ''), // 빈 Exercise 객체 반환
    );
  }
}
