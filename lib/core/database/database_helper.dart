import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/scan_history.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        scanned_at TEXT NOT NULL
      )
    ''');
  }

  // Insert a new scan record
  Future<int> insertScan(ScanHistory scan) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableName,
      scan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all scan history, ordered by most recent
  Future<List<ScanHistory>> getAllScans() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableName,
      orderBy: 'scanned_at DESC',
    );
    return maps.map((map) => ScanHistory.fromMap(map)).toList();
  }

  // Get scan by id
  Future<ScanHistory?> getScanById(int id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ScanHistory.fromMap(maps.first);
  }

  // Delete a scan record
  Future<int> deleteScan(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all scan history
  Future<int> deleteAllScans() async {
    final db = await database;
    return await db.delete(AppConstants.tableName);
  }

  // Get count of scans
  Future<int> getScanCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tableName}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}