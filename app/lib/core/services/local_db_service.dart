import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sathiai_offline.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  static Future<void> _createDB(Database db, int version) async {
    // Cache for Schemes
    await db.execute('''
      CREATE TABLE schemes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    // Cache for Skills
    await db.execute('''
      CREATE TABLE skills (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    // Cache for Market Prices
    await db.execute('''
      CREATE TABLE market_prices (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> cacheData(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    await db.insert(table, {
      'id': id,
      'title': data['title'] ?? id,
      'description': data['description'] ?? '',
      'data': data.toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getCachedData(String table) async {
    final db = await database;
    final maps = await db.query(table, orderBy: 'timestamp DESC');
    return maps;
  }

  static Future<void> clearCache(String table) async {
    final db = await database;
    await db.delete(table);
  }
}
