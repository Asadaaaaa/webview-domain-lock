import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyMainUrl = 'mainUrl';
  static const String _keyAllowedHost = 'allowedHost';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// Menyimpan mainUrl dan allowedHost ke local storage
  Future<void> saveConfig({
    required String mainUrl,
    required String allowedHost,
  }) async {
    await _prefs.setString(_keyMainUrl, mainUrl);
    await _prefs.setString(_keyAllowedHost, allowedHost);
  }

  /// Mengambil mainUrl yang tersimpan
  String? getMainUrl() {
    return _prefs.getString(_keyMainUrl);
  }

  /// Mengambil allowedHost yang tersimpan
  String? getAllowedHost() {
    return _prefs.getString(_keyAllowedHost);
  }

  /// Mengecek apakah konfigurasi URL sudah pernah disimpan
  bool hasSavedConfig() {
    final url = getMainUrl();
    final host = getAllowedHost();
    return url != null && url.isNotEmpty && host != null && host.isNotEmpty;
  }

  /// Menghapus konfigurasi URL yang tersimpan
  Future<void> clearConfig() async {
    await _prefs.remove(_keyMainUrl);
    await _prefs.remove(_keyAllowedHost);
  }
}
