import 'package:flutter/material.dart';

import '../models/bank_card.dart';
import '../services/app_services.dart';
import '../widgets/card_form.dart';

class EditCardScreen extends StatefulWidget {
  const EditCardScreen({super.key, required this.cardId});

  final int cardId;

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  BankCard? _card;
  bool _isLoading = true;
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
          _error = 'Failed to load card';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Card')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _card == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error ?? 'Card not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return CardForm(
      initialCard: _card,
      submitLabel: 'Update Card',
      onSubmit: (card) async {
        try {
          await AppServices.instance.cardRepository.updateCard(card);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card updated successfully')),
            );
            Navigator.pop(context);
          }
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update card')),
            );
          }
        }
      },
    );
  }
}
