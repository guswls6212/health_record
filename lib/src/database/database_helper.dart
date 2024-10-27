import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/exercise.dart';
import '../model/workout_record.dart';
import '../model/user.dart';

class DatabaseHelper {
  static final _databaseName = "health_app.db";
  static final _databaseVersion = 1;

  static final tableWorkoutRecords = 'workout_records';
  static final tableExercises = 'exercises';

  static final columnId = 'id';
  static final columnExerciseId = 'exercise_id';
  static final columnDate = 'date';
  static final columnSets = 'sets';
  static final columnName = 'name';
  static final columnBodyPart = 'body_part';
  static final columnIsDefault = 'is_default';

  static final tableUsers = 'users'; // User 테이블 추가
  static final columnUserEmail = 'user_email'; // 유저 이메일 컬럼
  static final columnSyncStatus = 'sync_status'; // 동기화 상태 컬럼
  static final columnVersion = 'version'; // 데이터 버전 컬럼
  static final columnLastSyncTime = 'last_sync_time'; // 마지막 동기화 시간 컬럼

  // 데이터베이스 인스턴스를 저장할 변수
  static Database? _database;

  // 데이터베이스 인스턴스를 가져오는 메서드
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // 데이터베이스를 초기화하는 메서드
  _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // 테이블을 생성하는 메서드
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableWorkoutRecords (
        $columnId TEXT PRIMARY KEY,
        $columnExerciseId TEXT NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnSets TEXT NOT NULL,
        $columnUserEmail TEXT,
        $columnSyncStatus INTEGER DEFAULT 0,
        $columnVersion INTEGER DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableExercises (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnBodyPart TEXT NOT NULL,
        $columnIsDefault INTEGER NOT NULL,
        $columnUserEmail TEXT,
        $columnSyncStatus INTEGER DEFAULT 0,
        $columnVersion INTEGER DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableUsers (
        $columnUserEmail TEXT PRIMARY KEY,
        $columnLastSyncTime INTEGER
      )
    ''');
  }

  // WorkoutRecord 관련 메서드 수정
  Future<void> insertWorkoutRecord(WorkoutRecord record) async {
    Database db = await this.database;
    await db.insert(tableWorkoutRecords, record.toMap());
  }

  Future<List<WorkoutRecord>> getWorkoutRecords() async {
    // userEmail 매개변수 제거
    Database db = await this.database;
    final List<Map<String, dynamic>> maps = await db.query(tableWorkoutRecords);
    return List.generate(maps.length, (i) {
      return WorkoutRecord.fromMap(maps[i]);
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

  // WorkoutRecord를 업데이트하는 메서드
  Future<void> updateWorkoutRecord(WorkoutRecord record) async {
    Database db = await this.database;
    await db.update(tableWorkoutRecords, record.toMap(),
        where: '$columnId = ?', whereArgs: [record.id]);
  }

  // WorkoutRecord를 삭제하는 메서드
  Future<void> deleteWorkoutRecord(String id) async {
    Database db = await this.database;
    await db
        .delete(tableWorkoutRecords, where: '$columnId = ?', whereArgs: [id]);
  }

  // Exercise 관련 메서드 수정
  Future<void> insertExercise(Exercise exercise) async {
    Database db = await this.database;
    await db.insert(tableExercises, exercise.toMap());
  }

  Future<List<Exercise>> getExercises() async {
    // userEmail 매개변수 제거
    Database db = await this.database;
    final List<Map<String, dynamic>> maps = await db.query(tableExercises);
    return List.generate(maps.length, (i) {
      return Exercise.fromMap(maps[i]);
    });
  }

  // Exercise를 업데이트하는 메서드
  Future<void> updateExercise(Exercise exercise) async {
    Database db = await this.database;
    await db.update(tableExercises, exercise.toMap(),
        where: '$columnId = ?', whereArgs: [exercise.id]);
  }

  // Exercise를 삭제하는 메서드
  Future<void> deleteExercise(String id) async {
    Database db = await this.database;
    await db.delete(tableExercises, where: '$columnId = ?', whereArgs: [id]);
  }

  // User 관련 메서드 추가
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
