// user_model.dart
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

// user.dart
class User {
  final String email; // 이메일 (기본키)
  String? name; // 이름 (선택사항)
  int? age; // 나이 (선택사항)
  String? gender; // 성별 (선택사항)
  double? height; // 키 (선택사항)
  double? weight; // 몸무게 (선택사항)
  String? profileImageUrl; // 프로필 이미지 URL (선택사항)
  DateTime? createdAt; // 계정 생성 시간 (선택사항)

  User({
    required this.email,
    this.name,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.profileImageUrl,
    this.createdAt,
  });

  // SQLite에 저장하기 위한 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // SQLite에서 데이터를 읽어올 때 Map을 User 객체로 변환
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] as String,
      name: map['name'] as String?,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      height: map['height'] as double?,
      weight: map['weight'] as double?,
      profileImageUrl: map['profileImageUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }
}

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