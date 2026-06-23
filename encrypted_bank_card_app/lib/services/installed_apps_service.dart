import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class BankingApp {
  final String name;
  final String packageName;
  final bool isInstalled;
  final String? version;

  const BankingApp({
    required this.name,
    required this.packageName,
    required this.isInstalled,
    this.version,
  });
}

class InstalledAppsService {
  static const List<Map<String, String>> _knownBankingApps = [
    {'name': 'آپ', 'package': 'ir.ada.app'},
    {'name': 'تاپ', 'package': 'com.tosan.amata'},
    {'name': 'ایوا', 'package': 'com.evam.evam'},
    {'name': 'بله', 'package': 'ir.bale.bale'},
    {'name': 'بام (ملت)', 'package': 'com.mellatbank.mobilebank'},
    {'name': 'همراه بانک صادرات', 'package': 'com.pmb.mobile'},
    {'name': 'همراه بانک شهر', 'package': 'com.citybank.mobile'},
    {'name': 'همراه بانک پارسیان', 'package': 'com.parsian.parsianmobilebank'},
    {'name': 'همراه بانک سامان', 'package': 'com.samanpr.banking'},
    {'name': 'همراه بانک پاسارگاد', 'package': 'com.pasargad.bank.mobilebank'},
    {'name': 'همراه بانک رفاه', 'package': 'com.refahbank.mobile'},
    {'name': 'همراه بانک تجارت', 'package': 'com.tejaratbank.mobile'},
    {'name': 'همراه بانک انصار', 'package': 'com.ansarbank.mobilebank'},
    {'name': 'همراه بانک اقتصاد نوین', 'package': 'com.eghtesadnovin.mobilebank'},
    {'name': 'همراه بانک کارآفرین', 'package': 'com.karafarinbank.mobilebank'},
    {'name': 'همراه بانک سرمایه', 'package': 'com.sarmayeh.mobilebank'},
    {'name': 'همراه بانک شهر', 'package': 'com.shahr.mobilebank'},
    {'name': 'همراه بانک دی', 'package': 'com.daybank.mobilebank'},
    {'name': 'همراه بانک گردشگری', 'package': 'com.gardeshgari.mobilebank'},
    {'name': 'همراه بانک ایران زمین', 'package': 'com.iranzamin.mobilebank'},
    {'name': 'همراه بانک مهر', 'package': 'com.mehr.mobilebank'},
    {'name': 'همراه بانک رسالت', 'package': 'com.resalat.mobilebank'},
    {'name': 'همراه بانک سپه', 'package': 'com.sepah.mobilebank'},
    {'name': 'همراه بانک سینا', 'package': 'com.sina.mobilebank'},
    {'name': 'همراه بانک گردشگری', 'package': 'com.tourism.mobilebank'},
  ];

  Future<List<BankingApp>> getInstalledBankingApps() async {
    final installed = <BankingApp>[];
    final seenPackages = <String>{};

    for (final app in _knownBankingApps) {
      final package = app['package']!;
      if (seenPackages.contains(package)) continue;
      seenPackages.add(package);

      try {
        final isInstalled = await InstalledApps.isAppInstalled(package);
        if (isInstalled == true) {
          AppInfo? info;
          try {
            info = await InstalledApps.getAppInfo(package, BuiltWith.flutter);
          } catch (_) {}

          installed.add(BankingApp(
            name: app['name']!,
            packageName: package,
            isInstalled: true,
            version: info?.versionName,
          ));
        }
      } catch (_) {}
    }

    return installed;
  }

  Future<bool> launchApp(String packageName) async {
    try {
      final launched = await InstalledApps.startApp(packageName);
      return launched ?? false;
    } catch (_) {
      return false;
    }
  }
}
