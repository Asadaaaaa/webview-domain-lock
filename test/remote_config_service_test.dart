import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_domain_lock/core/services/remote_config_service.dart';
import 'package:webview_domain_lock/core/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteConfigService Tests', () {
    late StorageService storageService;
    late RemoteConfigService remoteConfigService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs);
      remoteConfigService = RemoteConfigService(storageService);
    });

    test('getCachedOrDefaultConfig returns default fallback when no cached config', () {
      final config = remoteConfigService.getCachedOrDefaultConfig();
      expect(config.mainUrl, RemoteConfigService.defaultFallbackUrl);
      expect(config.allowedHost, RemoteConfigService.defaultFallbackHost);
    });

    test('getCachedOrDefaultConfig returns cached config when present', () async {
      await storageService.saveConfig(
        mainUrl: 'https://new-mirror.idlix.com',
        allowedHost: 'idlix.com',
      );

      final config = remoteConfigService.getCachedOrDefaultConfig();
      expect(config.mainUrl, 'https://new-mirror.idlix.com');
      expect(config.allowedHost, 'idlix.com');
    });

    test('config endpoints contain GitHub raw and jsdelivr CDN', () {
      expect(
        RemoteConfigService.configEndpoints,
        contains('https://raw.githubusercontent.com/Asadaaaaa/IDLIX-App/main/config.json'),
      );
      expect(
        RemoteConfigService.configEndpoints,
        contains('https://cdn.jsdelivr.net/gh/Asadaaaaa/IDLIX-App@main/config.json'),
      );
    });
  });
}
