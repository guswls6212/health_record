import '../../model/exercise.dart';
import '../database_helper.dart';

class ExerciseDao {
  final DatabaseHelper _databaseHelper;

  ExerciseDao(this._databaseHelper);

  Future<List<Exercise>> getDefaultExercises() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExercises,
      where: '${DatabaseHelper.columnIsDefault} = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Exercise.fromMap(maps[i]);
    });
  }

  Future<void> insertExercise(Exercise exercise) async {
    final db = await _databaseHelper.database;
    await db.insert(DatabaseHelper.tableExercises, exercise.toMap());
  }

  Future<List<Exercise>> getExercises() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExercises,
      orderBy: '${DatabaseHelper.columnSortOrder} ASC', // sortOrder 기준으로 정렬
    );
    return List.generate(maps.length, (i) {
      return Exercise.fromMap(maps[i]);
    });
  }

  Future<void> updateExercise(
      Exercise originalExercise, Exercise editedExercise) async {
    // originalExercise 추가
    final db = await _databaseHelper.database;
    await db.update(DatabaseHelper.tableExercises,
        editedExercise.toMap(), // editedExercise의 정보로 업데이트
        where: '${DatabaseHelper.columnName} = ?',
        whereArgs: [originalExercise.name]); // 원래 이름으로 검색
  }

  Future<void> deleteExercise(String name) async {
    // id 대신 name 사용
    final db = await _databaseHelper.database;
    await db.delete(DatabaseHelper.tableExercises,
        where: '${DatabaseHelper.columnName} = ?',
        whereArgs: [name]); // id 대신 name 사용
  }

  Future<List<Exercise>> getExercisesToSync(String userEmail) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExercises,
      where:
          '${DatabaseHelper.columnUserEmail} = ? AND ${DatabaseHelper.columnSyncStatus} = ?',
      whereArgs: [userEmail, 0],
    );
    return List.generate(maps.length, (i) {
      return Exercise.fromMap(maps[i]);
    });
  }

  Future<Exercise?> getExerciseByName(String name) async {
    // getExerciseByName 메서드 추가
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExercises,
      where: '${DatabaseHelper.columnName} = ?', // name으로 검색
      whereArgs: [name],
    );
    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<bool> hasDefaultExercises() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableExercises,
      where: '${DatabaseHelper.columnIsDefault} = ?',
      whereArgs: [1],
    );
    return result.isNotEmpty;
  }
}
