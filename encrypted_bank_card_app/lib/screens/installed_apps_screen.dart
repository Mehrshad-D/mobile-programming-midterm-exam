import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../services/installed_apps_service.dart';

class InstalledAppsScreen extends StatefulWidget {
  const InstalledAppsScreen({super.key});

  @override
  State<InstalledAppsScreen> createState() => _InstalledAppsScreenState();
}

class _InstalledAppsScreenState extends State<InstalledAppsScreen> {
  List<BankingApp> _installedApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() => _isLoading = true);
    try {
      final apps =
          await AppServices.instance.installedAppsService.getInstalledBankingApps();
      if (mounted) {
        setState(() {
          _installedApps = apps;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchApp(BankingApp app) async {
    if (!app.isInstalled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This application is not installed.')),
      );
      return;
    }

    final launched =
        await AppServices.instance.installedAppsService.launchApp(app.packageName);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the application.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banking Apps'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _installedApps.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.apps_outage,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No banking apps detected',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Installed Iranian banking and payment apps will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadApps,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _installedApps.length,
                    itemBuilder: (context, index) {
                      final app = _installedApps[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.account_balance,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(app.name),
                          subtitle: Text(
                            app.version != null
                                ? 'v${app.version}'
                                : app.packageName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: const Icon(Icons.launch),
                          onTap: () => _launchApp(app),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
