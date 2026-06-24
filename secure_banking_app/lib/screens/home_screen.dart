import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/otp_service.dart';
import '../widgets/secure_screen_mixin.dart';
import 'login_screen.dart';
import 'security_report_screen.dart';
import 'settings_screen.dart';

class MockTransaction {
  const MockTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isCredit,
  });

  final String title;
  final double amount;
  final String date;
  final bool isCredit;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SecureScreenMixin {
  static const String accountNumber = '6037-9912-8845-1203';
  static const double balance = 24_850_000;

  static const List<MockTransaction> transactions = [
    MockTransaction(
      title: 'Salary Deposit',
      amount: 15000000,
      date: '1404/03/01',
      isCredit: true,
    ),
    MockTransaction(
      title: 'Online Purchase',
      amount: -1250000,
      date: '1404/03/03',
      isCredit: false,
    ),
    MockTransaction(
      title: 'Utility Bill',
      amount: -890000,
      date: '1404/03/05',
      isCredit: false,
    ),
    MockTransaction(
      title: 'Transfer Received',
      amount: 3200000,
      date: '1404/03/07',
      isCredit: true,
    ),
  ];

  Future<void> _logout() async {
    await AuthService.instance.logout();
    OtpService.instance.clear();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _formatAmount(double amount) {
    final absValue = amount.abs().toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var i = 0; i < absValue.length; i++) {
      if (i > 0 && (absValue.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(absValue[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Banking'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Welcome back, Demo User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Number',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accountNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Available Balance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatAmount(balance)} IRR',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...transactions.map((tx) {
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (tx.isCredit ? Colors.green : Colors.red)
                        .withValues(alpha: 0.12),
                    child: Icon(
                      tx.isCredit
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: tx.isCredit ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  title: Text(tx.title),
                  subtitle: Text(tx.date),
                  trailing: Text(
                    '${tx.isCredit ? '+' : '-'}${_formatAmount(tx.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: tx.isCredit ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SecurityReportScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('Security Report'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
