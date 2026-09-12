import 'package:flutter/material.dart';
import 'package:webview_domain_lock/app/app.dart';
import 'package:webview_domain_lock/core/services/remote_config_service.dart';
import 'package:webview_domain_lock/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();
  final remoteConfigService = RemoteConfigService(storageService);
  final initialConfig = remoteConfigService.getCachedOrDefaultConfig();

  runApp(
    DomainLockApp(
      storageService: storageService,
      remoteConfigService: remoteConfigService,
      initialConfig: initialConfig,
      isTv: false,
    ),
  );
}
