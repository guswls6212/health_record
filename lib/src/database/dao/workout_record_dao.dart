import '../../model/workout_record.dart';
import '../../model/workout_set.dart';
import '../database_helper.dart';
import 'package:uuid/uuid.dart';

class WorkoutRecordDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> insertWorkoutRecord(WorkoutRecord record) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.insert(DatabaseHelper.tableWorkoutRecords, record.toMap());
      final workoutRecordId = record.id;

      final batch = txn.batch();
      for (var set in record.sets) {
        batch.insert(DatabaseHelper.tableWorkoutSets, {
          'id': const Uuid().v4(),
          'workout_record_id': workoutRecordId,
          'set_num': set.set,
          'weight': set.weight,
          'reps': set.reps,
          'duration': 0,
          'one_rm': set.oneRM,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<WorkoutRecord>> getWorkoutRecords() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> workoutRecordMaps =
        await db.query(DatabaseHelper.tableWorkoutRecords);

    final workoutRecords =
        await Future.wait(workoutRecordMaps.map((recordMap) async {
      final workoutRecordId = recordMap['id'] as String;
      final List<Map<String, dynamic>> workoutSetMaps = await db.query(
        DatabaseHelper.tableWorkoutSets,
        where: '${DatabaseHelper.columnWorkoutRecordId} = ?',
        whereArgs: [workoutRecordId],
      );

      final sets = workoutSetMaps.map((setMap) {
        return WorkoutSet(
          set: setMap['set_num'] as int?,
          weight: setMap['weight'] as double?,
          reps: setMap['reps'] as int?,
          duration: setMap['duration'] as int?,
          oneRM: setMap['one_rm'] as double?,
        );
      }).toList();

      return WorkoutRecord.fromMap({...recordMap, 'sets': sets});
    }));

    return workoutRecords;
  }

  Future<void> updateWorkoutRecord(WorkoutRecord record) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        DatabaseHelper.tableWorkoutRecords,
        record.toMap(),
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [record.id],
      );

      await txn.delete(
        DatabaseHelper.tableWorkoutSets,
        where: '${DatabaseHelper.columnWorkoutRecordId} = ?',
        whereArgs: [record.id],
      );

      final batch = txn.batch();
      for (var set in record.sets) {
        batch.insert(DatabaseHelper.tableWorkoutSets, {
          'id': const Uuid().v4(),
          'workout_record_id': record.id,
          'set_num': set.set,
          'weight': set.weight,
          'reps': set.reps,
          'duration': set.duration,
          'one_rm': set.oneRM,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> deleteWorkoutRecord(String id) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseHelper.tableWorkoutSets,
        where: '${DatabaseHelper.columnWorkoutRecordId} = ?',
        whereArgs: [id],
      );

      await txn.delete(
        DatabaseHelper.tableWorkoutRecords,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );
    });
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
