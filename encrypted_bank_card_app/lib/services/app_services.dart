import '../database/database_helper.dart';
import '../repositories/card_repository.dart';
import '../services/biometric_service.dart';
import '../services/encryption_service.dart';
import '../services/installed_apps_service.dart';
import '../services/nfc_service.dart';
import '../services/secure_storage_service.dart';

class AppServices {
  AppServices._();

  static final AppServices instance = AppServices._();

  late final DatabaseHelper databaseHelper;
  late final SecureStorageService secureStorage;
  late final EncryptionService encryption;
  late final CardRepository cardRepository;
  late final BiometricService biometricService;
  late final NfcService nfcService;
  late final InstalledAppsService installedAppsService;

  bool isInitialized = false;

  Future<void> initialize() async {
    if (isInitialized) return;

    databaseHelper = DatabaseHelper();
    secureStorage = SecureStorageService();
    encryption = EncryptionService(secureStorage);
    await encryption.initialize();
    await databaseHelper.database;

    cardRepository = CardRepository(databaseHelper, encryption);
    biometricService = BiometricService();
    nfcService = NfcService(databaseHelper);
    installedAppsService = InstalledAppsService();

    isInitialized = true;
  }

  Future<void> resetEncryptionKey() async {
    await encryption.resetKey();
    await databaseHelper.deleteAllCards();
  }
}
