import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../model/exercise.dart';
import '../model/workout_record.dart';
import '../model/user.dart';
import '../model/workout_set.dart';

class DatabaseHelper {
  static final _databaseName = "health_app.db";
  static final _databaseVersion = 1;

  static final tableWorkoutRecords = 'workout_records';
  static final tableExercises = 'exercises';
  static final tableBodyParts = 'body_parts';
  static final tableWorkoutSets = 'workout_sets';

  static final columnId = 'id';
  static final columnExerciseId = 'exercise_id';
  static final columnDate = 'date';
  static final columnSets = 'sets';
  static final columnName = 'name';
  static final columnBodyPartId = 'body_part_id';
  static final columnIsDefault = 'is_default';
  static final columnWorkoutRecordId = 'workout_record_id';
  static final columnWeight = 'weight'; // workout_sets 테이블의 weight 컬럼
  static final columnReps = 'reps'; // workout_sets 테이블의 reps 컬럼
  static final columnDuration = 'duration'; // workout_sets 테이블의 duration 컬럼

  static final tableUsers = 'users';
  static final columnUserEmail = 'user_email';
  static final columnSyncStatus = 'sync_status';
  static final columnVersion = 'version';
  static final columnLastSyncTime = 'last_sync_time';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableBodyParts (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableExercises (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnBodyPartId TEXT NOT NULL,
        $columnIsDefault INTEGER NOT NULL,
        $columnUserEmail TEXT,
        $columnSyncStatus INTEGER DEFAULT 0,
        $columnVersion INTEGER DEFAULT 1,
        FOREIGN KEY ($columnBodyPartId) REFERENCES $tableBodyParts($columnId)
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableWorkoutRecords (
        $columnId TEXT PRIMARY KEY,
        $columnExerciseId TEXT NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnUserEmail TEXT,
        $columnSyncStatus INTEGER DEFAULT 0,
        $columnVersion INTEGER DEFAULT 1,
        FOREIGN KEY ($columnExerciseId) REFERENCES $tableExercises($columnId)
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableWorkoutSets (
        $columnId TEXT PRIMARY KEY,
        $columnWorkoutRecordId TEXT NOT NULL,
        $columnWeight REAL,  -- weight 컬럼 추가
        $columnReps INTEGER,  -- reps 컬럼 추가
        $columnDuration INTEGER,  -- duration 컬럼 추가
        FOREIGN KEY ($columnWorkoutRecordId) REFERENCES $tableWorkoutRecords($columnId)
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableUsers (
        $columnUserEmail TEXT PRIMARY KEY,
        $columnLastSyncTime INTEGER
      )
    ''');
  }

  // WorkoutRecord 관련 메서드
  Future<void> insertWorkoutRecord(WorkoutRecord record) async {
    Database db = await this.database;
    await db.transaction((txn) async {
      final workoutRecordId = await txn.insert(tableWorkoutRecords, {
        'id': record.id,
        'exercise_id': record.exercise.id,
        'date': record.date.toIso8601String(),
        'user_email': record.exercise.bodyPart.name, // TODO: user_email 값 설정
        'sync_status': record.syncStatus ?? 0,
      });

      for (var set in record.sets) {
        await txn.insert(tableWorkoutSets, {
          'id': const Uuid().v4(),
          'workout_record_id': workoutRecordId,
          'weight': set.weight, // weight 값 추가
          'reps': set.reps, // reps 값 추가
          'duration': set.duration, // duration 값 추가
        });
      }
    });
  }

  Future<List<WorkoutRecord>> getWorkoutRecords() async {
    Database db = await this.database;
    final List<Map<String, dynamic>> workoutRecordMaps =
        await db.query(tableWorkoutRecords);

    final workoutRecords =
        await Future.wait(workoutRecordMaps.map((recordMap) async {
      final workoutRecordId = recordMap['id'] as String;
      final List<Map<String, dynamic>> workoutSetMaps = await db.query(
        tableWorkoutSets,
        where: '$columnWorkoutRecordId = ?',
        whereArgs: [workoutRecordId],
      );

      final sets = workoutSetMaps.map((setMap) {
        return WorkoutSet(
          weight: setMap['weight'] as double?,
          reps: setMap['reps'] as int?,
          duration: setMap['duration'] as int?,
        );
      }).toList();

      return WorkoutRecord.fromMap({...recordMap, 'sets': sets});
    }));

    return workoutRecords;
  }

  Future<void> updateWorkoutRecord(WorkoutRecord record) async {
    Database db = await this.database;
    await db.transaction((txn) async {
      await txn.update(
        tableWorkoutRecords,
        {
          'exercise_id': record.exercise.id,
          'date': record.date.toIso8601String(),
          'user_email': record.exercise.bodyPart.name, // TODO: user_email 값 설정
          'sync_status': record.syncStatus ?? 0,
        },
        where: '$columnId = ?',
        whereArgs: [record.id],
      );

      await txn.delete(
        tableWorkoutSets,
        where: '$columnWorkoutRecordId = ?',
        whereArgs: [record.id],
      );
      for (var set in record.sets) {
        await txn.insert(tableWorkoutSets, {
          'id': const Uuid().v4(),
          'workout_record_id': record.id,
          'weight': set.weight, // weight 값 추가
          'reps': set.reps, // reps 값 추가
          'duration': set.duration, // duration 값 추가
        });
      }
    });
  }

  Future<void> deleteWorkoutRecord(String id) async {
    Database db = await this.database;
    await db.transaction((txn) async {
      await txn.delete(
        tableWorkoutSets,
        where: '$columnWorkoutRecordId = ?',
        whereArgs: [id],
      );

      await txn.delete(
        tableWorkoutRecords,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    });
  }

  // 동기화되지 않은 WorkoutRecord 가져오기 (userEmail 사용)
  Future<List<WorkoutRecord>> getWorkoutRecordsToSync(String userEmail) async {
    Database db = await this.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableWorkoutRecords,
      where: '$columnUserEmail = ? AND $columnSyncStatus = ?',
      whereArgs: [userEmail, 0],
    );
    return List.generate(maps.length, (i) {
      return WorkoutRecord.fromMap(maps[i]);
    });
  }

  // Exercise 관련 메서드
  Future<void> insertExercise(Exercise exercise) async {
    Database db = await this.database;
    await db.insert(tableExercises, exercise.toMap());
  }

  Future<List<Exercise>> getExercises() async {
    Database db = await this.database;
    final List<Map<String, dynamic>> maps = await db.query(tableExercises);
    return List.generate(maps.length, (i) {
      return Exercise.fromMap(maps[i]);
    });
  }

  Future<void> updateExercise(Exercise exercise) async {
    Database db = await this.database;
    await db.update(tableExercises, exercise.toMap(),
        where: '$columnId = ?', whereArgs: [exercise.id]);
  }

  Future<void> deleteExercise(String id) async {
    Database db = await this.database;
    await db.delete(tableExercises, where: '$columnId = ?', whereArgs: [id]);
  }

  // 동기화되지 않은 Exercise 가져오기 (userEmail 사용)
  Future<List<Exercise>> getExercisesToSync(String userEmail) async {
    Database db = await this.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableExercises,
      where: '$columnUserEmail = ? AND $columnSyncStatus = ?',
      whereArgs: [userEmail, 0],
    );
    return List.generate(maps.length, (i) {
      return Exercise.fromMap(maps[i]);
    });
  }

  // User 관련 메서드
  Future<void> insertUser(User user) async {
    Database db = await this.database;
    await db.insert(tableUsers, user.toMap());
  }

  Future<User?> getUser(String email) async {
    Database db = await this.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnUserEmail = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    Database db = await this.database;
    await db.update(
      tableUsers,
      user.toMap(),
      where: '$columnUserEmail = ?',
      whereArgs: [user.email],
    );
  }

  Future<void> deleteUser(String email) async {
    Database db = await this.database;
    await db.delete(
      tableUsers,
      where: '$columnUserEmail = ?',
      whereArgs: [email],
    );
  }
}
