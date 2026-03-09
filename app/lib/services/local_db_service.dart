
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class LocalDatabaseService {
    static Future<void> cachePredictiveRecommendations(Map<String, dynamic> data) async {
      // Cache schemes
      if (data['schemes'] != null) {
        await cacheSchemes(data['schemes'] as List<dynamic>);
      }
      // Cache market
      if (data['market'] != null) {
        await cacheMarket(data['market'] as List<dynamic>);
      }
      // Cache skills (store as a simple key-value for now)
      // You can expand this to a full table if needed
      final db = await database;
      await db.execute('CREATE TABLE IF NOT EXISTS skills (id TEXT PRIMARY KEY, name TEXT, description TEXT, cached_at INTEGER)');
      if (data['skills'] != null) {
        final batch = db.batch();
        for (var skill in data['skills']) {
          batch.insert('skills', {
            'id': skill['id'] ?? skill['name'],
            'name': skill['name'],
            'description': skill['description'] ?? '',
            'cached_at': DateTime.now().millisecondsSinceEpoch,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      }
    }

    static Future<List<Map<String, dynamic>>> getCachedSkills() async {
      final db = await database;
      return await db.query('skills');
    }
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

  static Future _createDB(Database db, int version) async {
    // Schemes table for offline discovery
    await db.execute('''
      CREATE TABLE schemes (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        status TEXT,
        cached_at INTEGER
      )
    ''');

    // Market table for price stability checks
    await db.execute('''
      CREATE TABLE market (
        id TEXT PRIMARY KEY,
        crop TEXT,
        price TEXT,
        trend TEXT,
        advice TEXT,
        cached_at INTEGER
      )
    ''');
  }

  static Future<void> cacheSchemes(List<dynamic> schemes) async {
    final db = await database;
    final batch = db.batch();
    for (var scheme in schemes) {
      batch.insert('schemes', {
        'id': scheme['id'],
        'name': scheme['name'],
        'description': scheme['description'],
        'status': scheme['status'],
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getCachedSchemes() async {
    final db = await database;
    return await db.query('schemes');
  }

  static Future<void> cacheMarket(List<dynamic> items) async {
    final db = await database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert('market', {
        'id': item['id'],
        'crop': item['crop'],
        'price': item['price'],
        'trend': item['trend'],
        'advice': item['advice'] ?? '',
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getCachedMarket() async {
    final db = await database;
    return await db.query('market');
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('schemes');
    await db.delete('market');
  }
}
