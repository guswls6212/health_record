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
      orderBy: '${DatabaseHelper.columnSortOrder} ASC',
    );
    return List.generate(maps.length, (i) {
      return Exercise.fromMap(maps[i]);
    });
  }

  Future<void> updateExercise(
      Exercise originalExercise, Exercise editedExercise) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.tableExercises,
      editedExercise.toMap(),
      where: '${DatabaseHelper.columnName} = ?',
      whereArgs: [originalExercise.name],
    );
  }

  Future<void> deleteExercise(String name) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableExercises,
      where: '${DatabaseHelper.columnName} = ?',
      whereArgs: [name],
    );
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
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExercises,
      where: '${DatabaseHelper.columnName} = ?',
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
