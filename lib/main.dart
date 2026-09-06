import 'package:flutter/material.dart';
import 'package:webview_domain_lock/app/app.dart';
import 'package:webview_domain_lock/core/services/storage_service.dart';
import 'package:webview_domain_lock/features/webview/models/webview_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();

  WebViewConfig? initialConfig;
  if (storageService.hasSavedConfig()) {
    final url = storageService.getMainUrl()!;
    final host = storageService.getAllowedHost()!;
    initialConfig = WebViewConfig(
      mainUrl: url,
      allowedHost: host,
    );
  }

  runApp(
    DomainLockApp(
      storageService: storageService,
      initialConfig: initialConfig,
    ),
  );
}
