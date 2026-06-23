import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/app_services.dart';
import '../utils/app_theme.dart';
import 'biometric_lock_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAllCards(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Cards'),
        content: const Text(
          'This will permanently delete all stored cards. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await AppServices.instance.cardRepository.deleteAllCards();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All cards deleted')),
          );
          Navigator.pop(context, true);
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete cards')),
          );
        }
      }
    }
  }

  Future<void> _resetEncryptionKey(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Encryption Key'),
        content: const Text(
          'This will generate a new encryption key and delete all cards. '
          'Existing encrypted data will become unreadable. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await AppServices.instance.resetEncryptionKey();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Encryption key reset successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to reset encryption key')),
          );
        }
      }
    }
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      fadeSlideRoute(const BiometricLockScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.delete_sweep,
            title: 'Delete All Cards',
            subtitle: 'Remove all stored bank cards',
            color: Colors.red.shade400,
            onTap: () => _deleteAllCards(context),
          ),
          _SettingsTile(
            icon: Icons.vpn_key,
            title: 'Reset Encryption Key',
            subtitle: 'Generate new key and clear all data',
            color: Colors.orange.shade700,
            onTap: () => _resetEncryptionKey(context),
          ),
          _SettingsTile(
            icon: Icons.security,
            title: 'App Permissions',
            subtitle: 'Manage system permissions for this app',
            color: Colors.teal,
            onTap: () => openAppSettings(),
          ),
          const Divider(height: 32),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Return to biometric lock screen',
            color: AppTheme.primaryBlue,
            onTap: () => _logout(context),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'This app is for educational purposes only. Never store real banking credentials.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
