import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/dao/bodypart_dao.dart';

class BodyPart {
  final String name;
  int sortOrder;

  BodyPart({
    required this.name,
    this.sortOrder = 0,
  });

  factory BodyPart.fromMap(Map<String, dynamic> map) {
    return BodyPart(
      name: map['name'] as String,
      sortOrder: map['sort_order'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sort_order': sortOrder,
    };
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

  Future<void> addBodyPart(BodyPart bodyPart) async {
    bodyPart.sortOrder = _bodyParts.length;
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
