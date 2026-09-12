import 'package:flutter/material.dart';
import 'package:webview_domain_lock/core/services/remote_config_service.dart';
import 'package:webview_domain_lock/core/services/storage_service.dart';
import 'package:webview_domain_lock/features/webview/models/webview_config.dart';
import 'package:webview_domain_lock/features/webview/presentation/pages/webview_page.dart';

class DomainLockApp extends StatelessWidget {
  final StorageService storageService;
  final RemoteConfigService remoteConfigService;
  final WebViewConfig initialConfig;

  const DomainLockApp({
    super.key,
    required this.storageService,
    required this.remoteConfigService,
    required this.initialConfig,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDLIX TV & Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 1,
          centerTitle: false,
        ),
      ),
      home: WebViewPage(
        storageService: storageService,
        remoteConfigService: remoteConfigService,
        initialConfig: initialConfig,
      ),
    );
  }
}
