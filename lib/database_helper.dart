import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('social_connect.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        bio TEXT,
        profileImage TEXT
      )
    ''');

    // Posts Table
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT,
        postContent TEXT,
        imagePath TEXT,
        createdAt TEXT, 
        likes INTEGER DEFAULT 0
      )
    ''');

    // Default User
    await db.insert('users', {
      'name': 'Thushara', 
      'bio': 'Software Engineering Student',
      'profileImage': null
    });
  }

  // --- Post Methods ---
  Future<int> createPost(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('posts', row);
  }

  Future<List<Map<String, dynamic>>> queryAllPosts() async {
    final db = await instance.database;
    return await db.query('posts', orderBy: 'id DESC');
  }

  Future<void> updateLikes(int id, int currentLikes) async {
    final db = await instance.database;
    await db.update('posts', {'likes': currentLikes + 1}, where: 'id = ?', whereArgs: [id]);
  }

  // --- Profile Methods ---
  Future<Map<String, dynamic>> getProfile() async {
    final db = await instance.database;
    final maps = await db.query('users', limit: 1);
    return maps.isNotEmpty ? maps.first : {};
  }

  Future<void> updateProfile(String name, String bio, String? image) async {
    final db = await instance.database;
    await db.update('users', {'name': name, 'bio': bio, 'profileImage': image}, where: 'id = 1');
  }
}