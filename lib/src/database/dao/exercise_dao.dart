import '../../model/exercise.dart';
import '../database_helper.dart';

class ExerciseDao {
  final DatabaseHelper _databaseHelper; // DatabaseHelper 타입의 변수 선언

  ExerciseDao(this._databaseHelper); // 생성자를 통해 DatabaseHelper 객체를 전달받음

  Future<List<Exercise>> getDefaultExercises() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExercises,
      where: '${DatabaseHelper.columnIsDefault} = ?',
      whereArgs: [1], // isDefault가 true인 운동만 가져오기
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
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseHelper.tableExercises);
    return List.generate(maps.length, (i) {
      return Exercise.fromMap(maps[i]);
    });
  }

  Future<Exercise?> getExerciseById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExercises,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Exercise?> getExerciseByName(String name) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExercises,
      where: '${DatabaseHelper.columnName} = ?', // 'name' 컬럼을 기준으로 조회
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> updateExercise(Exercise exercise) async {
    final db = await _databaseHelper.database;
    await db.update(DatabaseHelper.tableExercises, exercise.toMap(),
        where: '${DatabaseHelper.columnId} = ?', whereArgs: [exercise.id]);
  }

  Future<void> deleteExercise(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(DatabaseHelper.tableExercises,
        where: '${DatabaseHelper.columnId} = ?', whereArgs: [id]);
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
}
