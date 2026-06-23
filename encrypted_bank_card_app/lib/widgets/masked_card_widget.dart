import 'package:flutter/material.dart';

import '../models/bank_card.dart';
import '../utils/app_theme.dart';

class MaskedCardWidget extends StatelessWidget {
  const MaskedCardWidget({
    super.key,
    required this.card,
    this.compact = false,
  });

  final BankCard card;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppTheme.cardGradientStart, AppTheme.cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.account_balance,
                color: Colors.white.withValues(alpha: 0.9),
                size: compact ? 24 : 32,
              ),
              Text(
                card.bankName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 16 : 28),
          Text(
            card.maskedCardNumber,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 18 : 22,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: compact ? 12 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARD HOLDER',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.cardHolderName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${card.expMonth}/${card.expYear}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
