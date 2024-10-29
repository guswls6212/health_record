import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/dao/bodypart_dao.dart';

class BodyPart {
  final String name;

  BodyPart({
    required this.name,
  });

  factory BodyPart.fromMap(Map<String, dynamic> map) {
    return BodyPart(
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

class BodyPartModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late BodyPartDao _bodyPartDao;

  BodyPartModel() {
    _bodyPartDao = BodyPartDao(_databaseHelper);
    loadBodyParts(); // 초기화 시 데이터 로드
  }

  List<BodyPart> _bodyParts = [];

  List<BodyPart> get bodyParts => _bodyParts;

  Future<void> loadBodyParts() async {
    _bodyParts = await _bodyPartDao.getBodyParts();
    notifyListeners();
  }

  Future<void> addBodyPart(BodyPart bodyPart) async {
    await _bodyPartDao.insertBodyPart(bodyPart);
    _bodyParts.add(bodyPart);
    notifyListeners();
  }

  Future<void> updateBodyPart(BodyPart bodyPart) async {
    await _bodyPartDao.updateBodyPart(bodyPart);
    final index = _bodyParts.indexWhere((e) => e.name == bodyPart.name);
    if (index != -1) {
      _bodyParts[index] = bodyPart;
      notifyListeners();
    }
  }

  Future<void> deleteBodyPart(String name) async {
    await _bodyPartDao.deleteBodyPart(name);
    _bodyParts.removeWhere((e) => e.name == name);
    notifyListeners();
  }
}
