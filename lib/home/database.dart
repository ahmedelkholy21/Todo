import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
class DB {
  Database? _db;

   Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT
          )
        ''');
      },
    );
  }

   Future<void> insertUser(String title, String description ) async {
    final db = await database;
    await db.insert('users', {
      'title': title,
      'description': description ,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

   Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

   Future<void> updateUser(int id, String title, String description ) async {
    final db = await database;
    await db.update(
      'users',
      {'title': title, 'description': description },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

   Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
