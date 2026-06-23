class BankCard {
  final int? id;
  final String cardNumber;
  final String cvv2;
  final String expMonth;
  final String expYear;
  final String bankName;
  final String cardHolderName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BankCard({
    this.id,
    required this.cardNumber,
    required this.cvv2,
    required this.expMonth,
    required this.expYear,
    required this.bankName,
    required this.cardHolderName,
    required this.createdAt,
    required this.updatedAt,
  });

  BankCard copyWith({
    int? id,
    String? cardNumber,
    String? cvv2,
    String? expMonth,
    String? expYear,
    String? bankName,
    String? cardHolderName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankCard(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cvv2: cvv2 ?? this.cvv2,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
      bankName: bankName ?? this.bankName,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cvv2': cvv2,
      'expMonth': expMonth,
      'expYear': expYear,
      'bankName': bankName,
      'cardHolderName': cardHolderName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BankCard.fromMap(Map<String, dynamic> map) {
    return BankCard(
      id: map['id'] as int?,
      cardNumber: map['cardNumber'] as String,
      cvv2: map['cvv2'] as String,
      expMonth: map['expMonth'] as String,
      expYear: map['expYear'] as String,
      bankName: map['bankName'] as String,
      cardHolderName: map['cardHolderName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory BankCard.fromJson(Map<String, dynamic> json) => BankCard.fromMap(json);

  String get lastFourDigits {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return digits;
    return digits.substring(digits.length - 4);
  }

  String get maskedCardNumber {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return digits;
    final first = digits.substring(0, 4);
    final last = digits.substring(digits.length - 4);
    return '$first **** **** $last';
  }
}
