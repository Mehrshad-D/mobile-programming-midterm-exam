import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../widgets/card_form.dart';

class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Card')),
      body: CardForm(
        submitLabel: 'Save Card',
        onSubmit: (card) async {
          try {
            await AppServices.instance.cardRepository.createCard(card);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card saved successfully')),
              );
              Navigator.pop(context);
            }
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to save card')),
              );
            }
          }
        },
      ),
    );
  }
}
