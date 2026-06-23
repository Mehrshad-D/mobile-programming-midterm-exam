import 'package:flutter/material.dart';

import '../models/bank_card.dart';
import '../services/app_services.dart';
import '../utils/app_theme.dart';
import '../widgets/card_tile.dart';
import 'add_card_screen.dart';
import 'card_detail_screen.dart';
import 'edit_card_screen.dart';
import 'installed_apps_screen.dart';
import 'nfc_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  List<BankCard> _cards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cards = await AppServices.instance.cardRepository.getCards();
      if (mounted) {
        setState(() {
          _cards = cards;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load cards. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDelete(BankCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text(
          'Are you sure you want to delete the card ending in ${card.lastFourDigits}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && card.id != null) {
      try {
        await AppServices.instance.cardRepository.deleteCard(card.id!);
        await _loadCards();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card deleted successfully')),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete card')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () async {
              await Navigator.push(
                context,
                fadeSlideRoute(const SearchScreen()),
              );
              _loadCards();
            },
          ),
          IconButton(
            icon: const Icon(Icons.nfc),
            tooltip: 'NFC',
            onPressed: () {
              Navigator.push(context, fadeSlideRoute(const NfcScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.apps),
            tooltip: 'Banking Apps',
            onPressed: () {
              Navigator.push(
                context,
                fadeSlideRoute(const InstalledAppsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () async {
              final shouldRefresh = await Navigator.push<bool>(
                context,
                fadeSlideRoute(const SettingsScreen()),
              );
              if (shouldRefresh == true) {
                _loadCards();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            fadeSlideRoute(const AddCardScreen()),
          );
          _loadCards();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCards,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.credit_card_off,
                size: 72,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No cards yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to add your first card.\nRemember: use test data only.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCards,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return CardTile(
            card: card,
            onTap: () {
              Navigator.push(
                context,
                fadeSlideRoute(CardDetailScreen(cardId: card.id!)),
              );
            },
            onEdit: () async {
              await Navigator.push(
                context,
                fadeSlideRoute(EditCardScreen(cardId: card.id!)),
              );
              _loadCards();
            },
            onDelete: () => _confirmDelete(card),
          );
        },
      ),
    );
  }
}
