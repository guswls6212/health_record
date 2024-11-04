import 'package:flutter/material.dart';
import 'package:health_record/src/model/exercise.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../database/dao/bodypart_dao.dart';

class BodyPart {
  final String name;
  int sortOrder;
  bool isDefault;

  BodyPart({
    required this.name,
    this.sortOrder = 0,
    this.isDefault = false,
  });

  factory BodyPart.fromMap(Map<String, dynamic> map) {
    return BodyPart(
      name: map['name'] as String,
      sortOrder: map['sort_order'] as int,
      isDefault: map['is_default'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sort_order': sortOrder,
      'is_default': isDefault ? 1 : 0,
    };
  }

  BodyPart copyWith({String? name, int? sortOrder}) {
    return BodyPart(
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class BodyPartModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late BodyPartDao _bodyPartDao;

  BodyPartDao get bodyPartDao => _bodyPartDao;

  BodyPartModel() {
    _bodyPartDao = BodyPartDao(_databaseHelper);
    loadBodyParts();
  }

  List<BodyPart> _bodyParts = [];

  List<BodyPart> get bodyParts => _bodyParts;

  Future<void> loadBodyParts() async {
    _bodyParts = await _bodyPartDao.getBodyParts();
    notifyListeners();
  }

  BodyPart getBodyPartByName(String name) {
    return _bodyParts.firstWhere((bodyPart) => bodyPart.name == name);
  }

  Future<void> addBodyPart(BodyPart bodyPart) async {
    bodyPart.sortOrder = _bodyParts.length;
    await _bodyPartDao.insertBodyPart(bodyPart);
    _bodyParts.add(bodyPart);
    notifyListeners();
  }

  Future<void> updateBodyPart(
      BodyPart bodyPart, String newName, ExerciseModel exerciseModel) async {
    // context 매개변수 추가
    final index = _bodyParts.indexWhere((e) => e.name == bodyPart.name);

    if (index != -1) {
      final updatedBodyPart =
          bodyPart.copyWith(name: newName, sortOrder: bodyPart.sortOrder);

      final exercisesToUpdate =
          await exerciseModel.getExercisesByBodyPart(bodyPart.name);

      // 각 Exercise의 bodyPart를 새로운 bodyPart로 업데이트합니다.
      for (var exercise in exercisesToUpdate) {
        final updatedExercise = exercise.copyWith(
          bodyPart: updatedBodyPart,
        );
        exerciseModel.editExercise(
            exercise, updatedExercise); // ExerciseModel 업데이트
      }

      // BodyPartModel 업데이트
      await _bodyPartDao.updateBodyPart(
          updatedBodyPart, bodyPart.name); // 수정 전 이름 전달
      _bodyParts[index] = updatedBodyPart;
      notifyListeners();
    }
  }

  Future<void> deleteBodyPart(String name) async {
    await _bodyPartDao.deleteBodyPart(name);
    _bodyParts.removeWhere((e) => e.name == name);
    notifyListeners();
  }
}
