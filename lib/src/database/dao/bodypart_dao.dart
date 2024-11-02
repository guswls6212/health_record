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

  Future<void> updateBodyPart(BodyPart bodyPart, String oldName) async {
    // oldName 매개변수 추가
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.tableBodyParts,
      bodyPart.toMap(),
      where: '${DatabaseHelper.columnName} = ?',
      whereArgs: [oldName], // where 조건에 oldName 사용
    );
  }

  Future<void> deleteBodyPart(String name) async {
    final db = await _databaseHelper.database;
    await db.delete(DatabaseHelper.tableBodyParts,
        where: '${DatabaseHelper.columnName} = ?', whereArgs: [name]);
  }

  Future<int> getLastSortOrder() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
        'SELECT MAX(sort_order) FROM ${DatabaseHelper.tableBodyParts}');
    return (result.first['MAX(sort_order)'] as int?) ?? -1; // null일 경우 -1 반환
  }

  Future<bool> hasDefaultBodyParts() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableBodyParts,
      where: '${DatabaseHelper.columnIsDefault} = ?',
      whereArgs: [1],
    );
    return result.isNotEmpty;
  }
}
