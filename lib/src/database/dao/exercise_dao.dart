import '../../exercise/exercise.dart';
import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

class ExerciseDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

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
