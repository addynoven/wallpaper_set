import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // Stream controller to broadcast database changes
  final _dbChangeController = StreamController<void>.broadcast();
  Stream<void> get onDatabaseChanged => _dbChangeController.stream;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wallpaper_favorites.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        asset_path TEXT NOT NULL UNIQUE,
        aspect_ratio REAL NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // Add a wallpaper to favorites
  Future<int> addFavorite(String assetPath, double aspectRatio) async {
    final db = await database;
    final id = await db.insert('favorites', {
      'asset_path': assetPath,
      'aspect_ratio': aspectRatio,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    _notifyListeners();
    return id;
  }

  // Remove a wallpaper from favorites
  Future<int> removeFavorite(String assetPath) async {
    final db = await database;
    final deletedCount = await db.delete(
      'favorites',
      where: 'asset_path = ?',
      whereArgs: [assetPath],
    );
    _notifyListeners();
    return deletedCount;
  }

  // Check if a wallpaper is in favorites
  Future<bool> isFavorite(String assetPath) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'asset_path = ?',
      whereArgs: [assetPath],
    );
    return result.isNotEmpty;
  }

  // Get all favorites
  Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final db = await database;
    return await db.query('favorites', orderBy: 'created_at DESC');
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String assetPath, double aspectRatio) async {
    final isFav = await isFavorite(assetPath);
    bool newStatus;
    if (isFav) {
      await removeFavorite(assetPath);
      newStatus = false;
    } else {
      await addFavorite(assetPath, aspectRatio);
      newStatus = true;
    }
    // Notification handled in add/remove methods, but specific toggle logic is fine too
    // Since add/remove already call _notifyListeners, we don't strictly need it here if we use them.
    // However, calling removeFavorite calls _notifyListeners, and addFavorite calls it too.
    // So one toggle might trigger it once (since we either add OR remove).
    return newStatus;
  }

  // Get favorites count
  Future<int> getFavoritesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM favorites');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  void _notifyListeners() {
    _dbChangeController.add(null);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    _dbChangeController.close();
  }
}
