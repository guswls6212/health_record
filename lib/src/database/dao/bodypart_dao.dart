import '../database_helper.dart';
import '../../model/body_part.dart';

class BodyPartDao {
  final DatabaseHelper _databaseHelper;

  BodyPartDao(this._databaseHelper);

  Future<BodyPart?> getBodyPartByName(String name) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableBodyParts, // 'body_parts' 테이블에서 조회
      where: '${DatabaseHelper.columnName} = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return BodyPart.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> insertBodyPart(BodyPart bodyPart) async {
    final db = await _databaseHelper.database;
    await db.insert(DatabaseHelper.tableBodyParts, bodyPart.toMap());
  }

  Future<List<BodyPart>> getBodyParts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseHelper.tableBodyParts);
    return List.generate(maps.length, (i) {
      return BodyPart.fromMap(maps[i]);
    });
  }

  Future<void> updateBodyPart(BodyPart bodyPart) async {
    final db = await _databaseHelper.database;
    await db.update(DatabaseHelper.tableBodyParts, bodyPart.toMap(),
        where: '${DatabaseHelper.columnName} = ?', whereArgs: [bodyPart.name]);
  }

  Future<void> deleteBodyPart(String name) async {
    final db = await _databaseHelper.database;
    await db.delete(DatabaseHelper.tableBodyParts,
        where: '${DatabaseHelper.columnName} = ?', whereArgs: [name]);
  }
}
