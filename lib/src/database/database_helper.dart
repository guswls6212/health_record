import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
  static const String columnOneRM = 'one_rm';

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
        $columnSortOrder INTEGER NOT NULL,
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
        $columnSortOrder INTEGER,
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
        $columnOneRM REAL,
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
}
