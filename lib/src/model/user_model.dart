// user_model.dart
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../user/user.dart';

class UserModel extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> loadUser(String email) async {
    final dbHelper = DatabaseHelper();
    _currentUser = await dbHelper.getUser(email);
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertUser(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.updateUser(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> deleteUser(String email) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteUser(email);
    _currentUser = null;
    notifyListeners();
  }
}
