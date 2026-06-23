import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bank_card.dart';

class CardForm extends StatefulWidget {
  const CardForm({
    super.key,
    this.initialCard,
    required this.onSubmit,
    required this.submitLabel,
  });

  final BankCard? initialCard;
  final Future<void> Function(BankCard card) onSubmit;
  final String submitLabel;

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cardNumberController;
  late final TextEditingController _cvvController;
  late final TextEditingController _expMonthController;
  late final TextEditingController _expYearController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _holderNameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final card = widget.initialCard;
    _cardNumberController = TextEditingController(text: card?.cardNumber ?? '');
    _cvvController = TextEditingController(text: card?.cvv2 ?? '');
    _expMonthController = TextEditingController(text: card?.expMonth ?? '');
    _expYearController = TextEditingController(text: card?.expYear ?? '');
    _bankNameController = TextEditingController(text: card?.bankName ?? '');
    _holderNameController =
        TextEditingController(text: card?.cardHolderName ?? '');
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cvvController.dispose();
    _expMonthController.dispose();
    _expYearController.dispose();
    _bankNameController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Card number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) return 'Card number must be 16 digits';
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'CVV2 is required';
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'CVV2 must be 3 or 4 digits';
    }
    return null;
  }

  String? _validateExpMonth(String? value) {
    if (value == null || value.isEmpty) return 'Month is required';
    final month = int.tryParse(value);
    if (month == null || month < 1 || month > 12) {
      return 'Enter a valid month (01-12)';
    }
    return null;
  }

  String? _validateExpYear(String? value) {
    if (value == null || value.isEmpty) return 'Year is required';
    if (!RegExp(r'^\d{2,4}$').hasMatch(value)) {
      return 'Enter a valid year';
    }
    final year = value.length == 2 ? 2000 + int.parse(value) : int.parse(value);
    final now = DateTime.now();
    final month = int.tryParse(_expMonthController.text) ?? 1;
    final expiry = DateTime(year, month + 1, 0);
    if (expiry.isBefore(DateTime(now.year, now.month))) {
      return 'Card has expired';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final cardNumber =
          _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
      final expMonth = _expMonthController.text.padLeft(2, '0');
      var expYear = _expYearController.text;
      if (expYear.length == 2) {
        expYear = '20$expYear';
      }

      final card = BankCard(
        id: widget.initialCard?.id,
        cardNumber: cardNumber,
        cvv2: _cvvController.text,
        expMonth: expMonth,
        expYear: expYear,
        bankName: _bankNameController.text.trim(),
        cardHolderName: _holderNameController.text.trim(),
        createdAt: widget.initialCard?.createdAt ?? now,
        updatedAt: now,
      );

      await widget.onSubmit(card);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              prefixIcon: Icon(Icons.credit_card),
              hintText: '1234 5678 9012 3456',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            validator: _validateCardNumber,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV2',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: _validateCvv,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _expMonthController,
                  decoration: const InputDecoration(
                    labelText: 'Exp. Month',
                    hintText: 'MM',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: _validateExpMonth,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _expYearController,
                  decoration: const InputDecoration(
                    labelText: 'Exp. Year',
                    hintText: 'YYYY',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: _validateExpYear,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bankNameController,
            decoration: const InputDecoration(
              labelText: 'Bank Name',
              prefixIcon: Icon(Icons.account_balance),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Bank name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _holderNameController,
            decoration: const InputDecoration(
              labelText: 'Card Holder Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Card holder name is required'
                : null,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSubmit,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
