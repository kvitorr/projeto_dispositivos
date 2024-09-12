import 'package:path/path.dart';
import 'package:projeto/models/users.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'flutter_sqflite_database.db');

    // Excluir o banco de dados existente
    await deleteDatabase(path);

    // Criar um novo banco de dados
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrEmail TEXT UNIQUE, usrName TEXT UNIQUE, usrNickname TEXT UNIQUE, usrPassword TEXT, biografia TEXT)",
    );
  }

  Future<Map<String, dynamic>?> getUserInfo(String userName) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'usrName = ?',
      whereArgs: [userName],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null; // Usuário não encontrado
    }
  }

  Future<void> updateUserInfo(String userName, String email, String biography) async {
    final db = await database;
    await db.update(
      'users',
      {
        'usrEmail': email,
        'biografia': biography,
      },
      where: 'usrName = ?',
      whereArgs: [userName],
    );
  }

  Future<bool> login(Users user) async {
    final Database db = await database;

    var result = await db.rawQuery(
        "SELECT * FROM users WHERE usrName = ? AND usrPassword = ?",
        [user.usrName, user.usrPassword]);
    return result.isNotEmpty;
  }

  Future<int> signup(Users user) async {
    final Database db = await database;

    return db.insert('users', user.toMap());
  }
}
