import 'package:flutter_test/flutter_test.dart';
import 'package:webview_domain_lock/features/update/models/app_update_info.dart';

void main() {
  group('AppUpdateInfo Tests', () {
    test('fromJson parses config.json fields properly', () {
      final json = {
        'url': 'https://z2.idlixku.com',
        'allowed_host': 'idlixku.com',
        'name': 'IDLIX',
        'updated_at': '2026-09-12',
        'latest_version': '1.6.0',
        'latest_version_code': 16,
        'release_notes': 'Update sinematik splashscreen dan in-app update.',
        'mobile_apk_url': 'https://github.com/Asadaaaaa/IDLIX-App/releases/download/v1.6.0/IDLIX.apk',
        'tv_apk_url': 'https://github.com/Asadaaaaa/IDLIX-App/releases/download/v1.6.0/IDLIX-TV.apk'
      };

      final info = AppUpdateInfo.fromJson(json);

      expect(info.version, '1.6.0');
      expect(info.versionCode, 16);
      expect(info.releaseNotes, 'Update sinematik splashscreen dan in-app update.');
      expect(info.mobileApkUrl, 'https://github.com/Asadaaaaa/IDLIX-App/releases/download/v1.6.0/IDLIX.apk');
      expect(info.tvApkUrl, 'https://github.com/Asadaaaaa/IDLIX-App/releases/download/v1.6.0/IDLIX-TV.apk');
    });

    test('fromJson handles fallback defaults when keys missing', () {
      final json = <String, dynamic>{};
      final info = AppUpdateInfo.fromJson(json);

      expect(info.version, '');
      expect(info.versionCode, 0);
      expect(info.mobileApkUrl, contains('IDLIX.apk'));
      expect(info.tvApkUrl, contains('IDLIX-TV.apk'));
    });
  });
}
