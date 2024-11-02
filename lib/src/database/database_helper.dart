import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../model/exercise.dart';
import '../model/workout_record.dart';
import '../model/user.dart';
import '../model/workout_set.dart';
import '../model/body_part.dart';

class DatabaseHelper {
  static final _databaseName = "health_app.db";
  static final _databaseVersion = 1;

  static final tableWorkoutRecords = 'workout_records';
  static final tableExercises = 'exercises';
  static final tableBodyParts = 'body_parts';
  static final tableWorkoutSets = 'workout_sets';

  static final columnId = 'id';
  static final columnExerciseName = 'exercise_name';
  static final columnDate = 'date';
  static final columnSets = 'sets';
  static final columnName = 'name';
  static final columnBodyPartName = 'body_part_name';
  static final columnIsDefault = 'is_default';
  static final columnWorkoutRecordId = 'workout_record_id';
  static final columnWeight = 'weight';
  static final columnReps = 'reps';
  static final columnDuration = 'duration';
  static final columnSetNum = 'set_num';
  static final columnSortOrder = 'sort_order';

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
        $columnName TEXT PRIMARY KEY,
        $columnSortOrder INTEGER NOT NULL,  -- sort_order 컬럼 추가 및 NOT NULL 제약 조건 설정
        $columnIsDefault INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableExercises (
        $columnName TEXT PRIMARY KEY,
        $columnBodyPartName TEXT NOT NULL,
        $columnIsDefault INTEGER NOT NULL,
        $columnUserEmail TEXT,
        $columnSyncStatus INTEGER DEFAULT 0,
        $columnVersion INTEGER DEFAULT 1,
        $columnSortOrder INTEGER,  -- sort_order 컬럼 추가
        FOREIGN KEY ($columnBodyPartName) REFERENCES $tableBodyParts($columnName)
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableWorkoutRecords (
        $columnId TEXT PRIMARY KEY,
        $columnExerciseName TEXT NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnUserEmail TEXT,
        $columnSyncStatus INTEGER DEFAULT 0,
        $columnVersion INTEGER DEFAULT 1,
        FOREIGN KEY ($columnExerciseName) REFERENCES $tableExercises($columnName)
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableWorkoutSets (
        $columnId TEXT PRIMARY KEY,
        $columnWorkoutRecordId TEXT NOT NULL,
        $columnSetNum INTEGER,
        $columnWeight REAL,
        $columnReps INTEGER,
        $columnDuration INTEGER,
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
        'exercise_name': record.exercise.name,
        'date': record.date.toIso8601String(),
        'user_email': record.exercise.bodyPart.name, // TODO: user_email 값 설정
        'sync_status': record.syncStatus ?? 0,
      });

      for (var set in record.sets) {
        await txn.insert(tableWorkoutSets, {
          'id': const Uuid().v4(),
          'workout_record_id': workoutRecordId,
          'set_num': set.set,
          'weight': set.weight,
          'reps': set.reps,
          'duration': set.duration,
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
          set: setMap['set_num'] as int?,
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
          'exercise_name': record.exercise.name,
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
          'set_num': set.set,
          'weight': set.weight,
          'reps': set.reps,
          'duration': set.duration,
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
        where: '$columnName = ?', whereArgs: [exercise.name]);
  }

  Future<void> deleteExercise(String name) async {
    Database db = await this.database;
    await db
        .delete(tableExercises, where: '$columnName = ?', whereArgs: [name]);
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

  // BodyPart 관련 메서드
  Future<void> insertBodyPart(BodyPart bodyPart) async {
    Database db = await this.database;
    await db.insert(
        tableBodyParts, bodyPart.toMap()); // bodyPart.toMap()에서 sort_order 값 포함
  }

  Future<List<BodyPart>> getBodyParts() async {
    Database db = await this.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableBodyParts,
      orderBy: '$columnSortOrder ASC',
    );
    return List.generate(maps.length, (i) {
      return BodyPart.fromMap(maps[i]);
    });
  }

  Future<void> updateBodyPart(BodyPart bodyPart) async {
    Database db = await this.database;
    await db.update(
      tableBodyParts,
      bodyPart.toMap(),
      where: '$columnName = ?',
      whereArgs: [bodyPart.name],
    );
  }

  Future<void> deleteBodyPart(String name) async {
    Database db = await this.database;
    await db
        .delete(tableBodyParts, where: '$columnName = ?', whereArgs: [name]);
  }
}
