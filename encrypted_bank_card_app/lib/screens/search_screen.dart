import 'package:flutter/material.dart';

import '../models/bank_card.dart';
import '../services/app_services.dart';
import '../utils/app_theme.dart';
import '../widgets/card_tile.dart';
import 'card_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<BankCard> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text;
    setState(() => _isSearching = true);
    try {
      final results =
          await AppServices.instance.cardRepository.searchCards(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Cards'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Bank name, holder, or last 4 digits...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (_results.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'Start typing to search'
                      : 'No cards found',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final card = _results[index];
                  return CardTile(
                    card: card,
                    onTap: () {
                      if (card.id != null) {
                        Navigator.push(
                          context,
                          fadeSlideRoute(CardDetailScreen(cardId: card.id!)),
                        );
                      }
                    },
                    onEdit: () {},
                    onDelete: () {},
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
