import '../database/database_helper.dart';
import '../models/bank_card.dart';
import '../services/encryption_service.dart';

class CardRepository {
  CardRepository(this._dbHelper, this._encryption);

  final DatabaseHelper _dbHelper;
  final EncryptionService _encryption;

  Map<String, dynamic> _encryptCardFields(BankCard card) {
    return {
      'cardNumber': _encryption.encrypt(card.cardNumber),
      'cvv2': _encryption.encrypt(card.cvv2),
      'expMonth': _encryption.encrypt(card.expMonth),
      'expYear': _encryption.encrypt(card.expYear),
      'bankName': card.bankName,
      'cardHolderName': card.cardHolderName,
      'createdAt': card.createdAt.toIso8601String(),
      'updatedAt': card.updatedAt.toIso8601String(),
    };
  }

  BankCard _decryptCard(Map<String, dynamic> map) {
    return BankCard(
      id: map['id'] as int?,
      cardNumber: _encryption.decrypt(map['cardNumber'] as String),
      cvv2: _encryption.decrypt(map['cvv2'] as String),
      expMonth: _encryption.decrypt(map['expMonth'] as String),
      expYear: _encryption.decrypt(map['expYear'] as String),
      bankName: map['bankName'] as String,
      cardHolderName: map['cardHolderName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Future<int> createCard(BankCard card) async {
    final db = await _dbHelper.database;
    final data = _encryptCardFields(card);
    return db.insert(DatabaseHelper.cardsTable, data);
  }

  Future<List<BankCard>> getCards() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DatabaseHelper.cardsTable,
      orderBy: 'updatedAt DESC',
    );
    return rows.map(_decryptCard).toList();
  }

  Future<BankCard?> getCardById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DatabaseHelper.cardsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _decryptCard(rows.first);
  }

  Future<int> updateCard(BankCard card) async {
    if (card.id == null) {
      throw ArgumentError('Card id is required for update.');
    }
    final db = await _dbHelper.database;
    final data = _encryptCardFields(card);
    return db.update(
      DatabaseHelper.cardsTable,
      data,
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      DatabaseHelper.cardsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllCards() async {
    await _dbHelper.deleteAllCards();
  }

  Future<List<BankCard>> searchCards(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return getCards();

    final allCards = await getCards();
    return allCards.where((card) {
      final bankMatch = card.bankName.toLowerCase().contains(normalized);
      final holderMatch =
          card.cardHolderName.toLowerCase().contains(normalized);
      final lastFourMatch = card.lastFourDigits.contains(normalized);
      return bankMatch || holderMatch || lastFourMatch;
    }).toList();
  }
}
