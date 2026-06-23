import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/bank_card.dart';
import '../services/app_services.dart';
import '../widgets/masked_card_widget.dart';
import 'edit_card_screen.dart';

class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({super.key, required this.cardId});

  final int cardId;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  BankCard? _card;
  bool _isLoading = true;
  bool _showSensitive = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    try {
      final card =
          await AppServices.instance.cardRepository.getCardById(widget.cardId);
      if (mounted) {
        setState(() {
          _card = card;
          _isLoading = false;
          if (card == null) _error = 'Card not found';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Failed to decrypt card data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        actions: [
          if (_card != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditCardScreen(cardId: widget.cardId),
                  ),
                );
                _loadCard();
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _card == null) {
      return Center(child: Text(_error ?? 'Card not found'));
    }

    final card = _card!;
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        MaskedCardWidget(card: card),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sensitive Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _showSensitive = !_showSensitive),
                      icon: Icon(
                        _showSensitive
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      tooltip: _showSensitive ? 'Hide' : 'Show',
                    ),
                  ],
                ),
                const Divider(),
                _detailRow('Bank', card.bankName),
                _detailRow('Card Holder', card.cardHolderName),
                _detailRow(
                  'Card Number',
                  _showSensitive ? card.cardNumber : card.maskedCardNumber,
                ),
                _detailRow(
                  'CVV2',
                  _showSensitive ? card.cvv2 : '***',
                ),
                _detailRow(
                  'Expiry',
                  '${card.expMonth}/${card.expYear}',
                ),
                const SizedBox(height: 12),
                _detailRow(
                  'Created',
                  dateFormat.format(card.createdAt),
                ),
                _detailRow(
                  'Updated',
                  dateFormat.format(card.updatedAt),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
