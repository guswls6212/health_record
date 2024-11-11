import '../database_helper.dart';
import '../../model/workout_set.dart';
import 'package:uuid/uuid.dart';

class WorkoutSetDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> insertWorkoutSets(List<WorkoutSet> sets, String recordId) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();
    for (var set in sets) {
      batch.insert(DatabaseHelper.tableWorkoutSets, {
        'id': const Uuid().v4(),
        'workout_record_id': recordId,
        'set_num': set.set,
        'weight': set.weight,
        'reps': set.reps,
        'duration': set.duration,
        'one_rm': set.oneRM,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<WorkoutSet>> getWorkoutSetsByRecordId(String recordId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableWorkoutSets,
      where: '${DatabaseHelper.columnWorkoutRecordId} = ?',
      whereArgs: [recordId],
    );
    return List.generate(maps.length, (i) {
      return WorkoutSet.fromMap(maps[i]);
    });
  }

  Future<void> updateWorkoutSets(List<WorkoutSet> sets, String recordId) async {
    final db = await _databaseHelper.database;
    await deleteWorkoutSetsByRecordId(recordId); // 기존 세트 삭제
    await insertWorkoutSets(sets, recordId); // 새로운 세트 추가
  }

  Future<void> deleteWorkoutSetsByRecordId(String recordId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableWorkoutSets,
      where: '${DatabaseHelper.columnWorkoutRecordId} = ?',
      whereArgs: [recordId],
    );
  }
}
