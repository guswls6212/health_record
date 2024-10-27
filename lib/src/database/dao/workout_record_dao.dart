import '../../model/workout_record.dart';
import '../database_helper.dart';

class WorkoutRecordDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> insertWorkoutRecord(WorkoutRecord record) async {
    final db = await _databaseHelper.database;
    await db.insert(DatabaseHelper.tableWorkoutRecords, record.toMap());
  }

  Future<List<WorkoutRecord>> getWorkoutRecords() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseHelper.tableWorkoutRecords);
    return List.generate(maps.length, (i) {
      return WorkoutRecord.fromMap(maps[i]);
    });
  }

  Future<void> updateWorkoutRecord(WorkoutRecord record) async {
    final db = await _databaseHelper.database;
    await db.update(DatabaseHelper.tableWorkoutRecords, record.toMap(),
        where: '${DatabaseHelper.columnId} = ?', whereArgs: [record.id]);
  }

  Future<void> deleteWorkoutRecord(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(DatabaseHelper.tableWorkoutRecords,
        where: '${DatabaseHelper.columnId} = ?', whereArgs: [id]);
  }

  Future<List<WorkoutRecord>> getWorkoutRecordsToSync(String userEmail) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableWorkoutRecords,
      where:
          '${DatabaseHelper.columnUserEmail} = ? AND ${DatabaseHelper.columnSyncStatus} = ?',
      whereArgs: [userEmail, 0],
    );
    return List.generate(maps.length, (i) {
      return WorkoutRecord.fromMap(maps[i]);
    });
  }
}
