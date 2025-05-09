import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:journal/data/models/journal_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'journal.db');

    return await openDatabase(dbPath, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        imageUrl TEXT,
        mood TEXT,
        tags TEXT
      )
    ''');
  }

  Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert('entries', entry.toMap());
  }

  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update('entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<JournalEntry?> getEntry(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('entries', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return JournalEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<JournalEntry>> getAllEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('entries', orderBy: 'createdAt DESC');

    return List.generate(maps.length, (i) {
      return JournalEntry.fromMap(maps[i]);
    });
  }

  Future<List<JournalEntry>> getEntriesByDate(DateTime date) async {
    final db = await database;

    // Format the date to yyyy-MM-dd for comparison
    final String dateStr = date.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      where: "createdAt LIKE ?",
      whereArgs: ['$dateStr%'],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return JournalEntry.fromMap(maps[i]);
    });
  }
}
