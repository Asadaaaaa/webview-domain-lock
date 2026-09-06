import 'package:webview_domain_lock/core/utils/domain_utils.dart';

class WebViewAdBlockService {
  /// Memeriksa apakah URL yang diminta adalah domain iklan.
  bool isAdUrl(String url) {
    return DomainUtils.isBlockedAdDomain(url);
  }
}
