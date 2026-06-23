import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'bank_cards.db';
  static const int _databaseVersion = 1;

  static const String cardsTable = 'cards';
  static const String nfcNotesTable = 'nfc_notes';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $cardsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cardNumber TEXT NOT NULL,
        cvv2 TEXT NOT NULL,
        expMonth TEXT NOT NULL,
        expYear TEXT NOT NULL,
        bankName TEXT NOT NULL,
        cardHolderName TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $nfcNotesTable (
        tagId TEXT PRIMARY KEY,
        note TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteAllCards() async {
    final db = await database;
    await db.delete(cardsTable);
  }
}
