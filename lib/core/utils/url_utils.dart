class UrlUtils {
  /// Melakukan normalisasi URL.
  /// Jika user memasukkan URL tanpa skema, tambahkan "https://".
  static String normalizeUrl(String input) {
    String trimmed = input.trim();
    if (trimmed.isEmpty) return '';

    // Cek apakah sudah memiliki protokol/skema
    final lower = trimmed.toLowerCase();
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
      // Jika memiliki skema lain (misal whatsapp://), jangan paksa https:// agar tetap terdeteksi oleh validator
      if (RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(trimmed)) {
        return trimmed;
      }
      return 'https://$trimmed';
    }
    return trimmed;
  }

  /// Memvalidasi apakah URL memiliki skema HTTP/HTTPS dan host yang sah.
  static bool isValidUrl(String input) {
    final normalized = normalizeUrl(input);
    if (normalized.isEmpty) return false;

    final uri = Uri.tryParse(normalized);
    if (uri == null) return false;

    // Harus skema HTTP atau HTTPS
    if (uri.scheme.toLowerCase() != 'http' && uri.scheme.toLowerCase() != 'https') {
      return false;
    }

    // Harus memiliki host yang tidak kosong
    if (uri.host.isEmpty) return false;

    // Host harus memiliki setidaknya nama dan TLD (misal example.com atau localhost)
    final host = uri.host.trim();
    if (host == 'localhost') return true;

    // Validasi format hostname sederhana (tidak mengandung karakter terlarang)
    final hostRegex = RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$');
    return hostRegex.hasMatch(host);
  }

  /// Memeriksa apakah skema URL hanya HTTP atau HTTPS.
  static bool isAllowedScheme(String urlString) {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return false;
    final scheme = uri.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https';
  }
}
