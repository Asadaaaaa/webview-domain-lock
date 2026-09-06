import 'package:webview_domain_lock/core/utils/domain_utils.dart';
import 'package:webview_domain_lock/core/utils/url_utils.dart';
import 'package:webview_domain_lock/features/webview/services/webview_adblock_service.dart';

enum NavigationResult {
  allowed,
  blockedInvalidScheme,
  blockedAdDomain,
  blockedExternalDomain,
}

class WebViewNavigationService {
  final WebViewAdBlockService _adBlockService;

  WebViewNavigationService({WebViewAdBlockService? adBlockService})
      : _adBlockService = adBlockService ?? WebViewAdBlockService();

  /// Mengevaluasi request navigasi berdasarkan prioritas pemeriksaan (Bagian 15):
  /// 1. Skema harus HTTP atau HTTPS (blokir intent, whatsapp, mailto, tel, dll.)
  /// 2. Bukan domain iklan
  /// 3. Harus sesuai allowed domain atau subdomainnya
  NavigationResult evaluateNavigation(String url, String allowedHost) {
    // Prioritas 1: Periksa Skema
    if (!UrlUtils.isAllowedScheme(url)) {
      return NavigationResult.blockedInvalidScheme;
    }

    // Prioritas 2: Periksa Ad Blocklist
    if (_adBlockService.isAdUrl(url)) {
      return NavigationResult.blockedAdDomain;
    }

    // Prioritas 3: Periksa Domain yang diizinkan (Allowlist)
    if (!DomainUtils.isAllowedDomain(url, allowedHost)) {
      return NavigationResult.blockedExternalDomain;
    }

    return NavigationResult.allowed;
  }

  /// Menghasilkan true jika request diizinkan untuk dinavigasikan
  bool shouldAllowNavigation(String url, String allowedHost) {
    return evaluateNavigation(url, allowedHost) == NavigationResult.allowed;
  }
}
