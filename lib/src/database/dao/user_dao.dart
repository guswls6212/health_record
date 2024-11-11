import '../../model/user.dart';
import '../database_helper.dart';

class UserDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> insertUser(User user) async {
    final db = await _databaseHelper.database;
    await db.insert(DatabaseHelper.tableUsers, user.toMap());
  }

  Future<User?> getUser(String email) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableUsers,
      where: '${DatabaseHelper.columnUserEmail} = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.tableUsers,
      user.toMap(),
      where: '${DatabaseHelper.columnUserEmail} = ?',
      whereArgs: [user.email],
    );
  }

  Future<void> deleteUser(String email) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableUsers,
      where: '${DatabaseHelper.columnUserEmail} = ?',
      whereArgs: [email],
    );
  }
}
