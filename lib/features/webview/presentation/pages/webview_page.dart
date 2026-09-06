import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_domain_lock/core/services/storage_service.dart';
import 'package:webview_domain_lock/features/webview/models/webview_config.dart';
import 'package:webview_domain_lock/features/webview/presentation/widgets/loading_overlay.dart';
import 'package:webview_domain_lock/features/webview/presentation/widgets/url_input_dialog.dart';
import 'package:webview_domain_lock/features/webview/services/webview_navigation_service.dart';

class WebViewPage extends StatefulWidget {
  final StorageService storageService;
  final WebViewConfig? initialConfig;

  const WebViewPage({
    super.key,
    required this.storageService,
    this.initialConfig,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewNavigationService _navigationService;
  WebViewController? _controller;
  WebViewConfig? _config;

  bool _isLoading = true;
  int _loadingProgress = 0;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _navigationService = WebViewNavigationService();
    _config = widget.initialConfig;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_config == null) {
        _showInitialUrlDialog();
      } else {
        _initializeWebView();
      }
    });
  }

  /// Menampilkan dialog input URL pertama kali saat aplikasi dibuka
  Future<void> _showInitialUrlDialog() async {
    final result = await showDialog<WebViewConfig>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UrlInputDialog(
        canDismiss: false,
        title: 'Open Website',
        submitButtonText: 'Open',
      ),
    );

    if (result != null && mounted) {
      await widget.storageService.saveConfig(
        mainUrl: result.mainUrl,
        allowedHost: result.allowedHost,
      );
      setState(() {
        _config = result;
      });
      _initializeWebView();
    }
  }

  /// Membuka dialog pengaturan untuk mengganti URL utama
  Future<void> _openSettingsDialog() async {
    final result = await showDialog<WebViewConfig>(
      context: context,
      builder: (context) => UrlInputDialog(
        canDismiss: true,
        initialUrl: _config?.mainUrl,
        title: 'Settings - Change URL',
        submitButtonText: 'Save & Reload',
      ),
    );

    if (result != null && mounted) {
      await widget.storageService.saveConfig(
        mainUrl: result.mainUrl,
        allowedHost: result.allowedHost,
      );
      setState(() {
        _config = result;
        _hasError = false;
        _errorMessage = null;
        _isLoading = true;
      });

      if (_controller != null) {
        await _controller!.clearCache();
        await _controller!.loadRequest(Uri.parse(result.mainUrl));
      } else {
        _initializeWebView();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Domain lock updated to: ${result.allowedHost}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Inisialisasi WebViewController beserta pengamanan navigasi dan popup
  void _initializeWebView() {
    if (_config == null) return;

    final WebViewController controller = WebViewController();

    // Set platform-specific params jika di Android
    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(true);
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              // Injeksi JS untuk mencegah popup window.open dan target="_blank"
              _preventPopupsAndNewWindows(controller);
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Hanya tangani error level halaman utama (bukan resource minor seperti favicon yang gagal)
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = 'Unable to load website: ${error.description}';
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final allowedHost = _config?.allowedHost ?? '';
            final eval = _navigationService.evaluateNavigation(request.url, allowedHost);

            if (eval == NavigationResult.allowed) {
              return NavigationDecision.navigate;
            }

            // Blokir navigasi
            _handleBlockedNavigation(eval, request.url);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(_config!.mainUrl));

    setState(() {
      _controller = controller;
    });
  }

  /// JavaScript injection untuk mengarahkan window.open dan target="_blank" ke dalam WebView
  /// sehingga tetap dievaluasi oleh NavigationDelegate
  void _preventPopupsAndNewWindows(WebViewController controller) {
    const jsScript = '''
      (function() {
        // Override window.open agar membuka di frame saat ini
        window.open = function(url) {
          if (url) {
            window.location.href = url;
          }
          return null;
        };

        // Mengubah target="_blank" menjadi target="_self"
        function sanitizeLinks() {
          var links = document.getElementsByTagName('a');
          for (var i = 0; i < links.length; i++) {
            if (links[i].getAttribute('target') === '_blank') {
              links[i].setAttribute('target', '_self');
            }
          }
        }

        sanitizeLinks();
        // Amati perubahan DOM
        var observer = new MutationObserver(function() {
          sanitizeLinks();
        });
        if (document.body) {
          observer.observe(document.body, { childList: true, subtree: true });
        }
      })();
    ''';
    controller.runJavaScript(jsScript).catchError((_) {});
  }

  void _handleBlockedNavigation(NavigationResult result, String url) {
    if (!mounted) return;

    String reason;
    switch (result) {
      case NavigationResult.blockedInvalidScheme:
        reason = 'External app or invalid scheme blocked';
        break;
      case NavigationResult.blockedAdDomain:
        reason = 'Ad domain blocked';
        break;
      case NavigationResult.blockedExternalDomain:
        reason = 'External domain blocked';
        break;
      case NavigationResult.allowed:
        return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$reason ($url)'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Future<void> _handleBackPress() async {
    if (_controller != null && await _controller!.canGoBack()) {
      await _controller!.goBack();
    } else {
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _config?.allowedHost ?? 'WebView Domain Lock',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload',
              onPressed: () {
                if (_controller != null) {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                  });
                  _controller!.reload();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: _openSettingsDialog,
            ),
          ],
        ),
        body: Stack(
          children: [
            if (_controller != null && !_hasError)
              WebViewWidget(controller: _controller!),
            if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to load website.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _errorMessage = null;
                          });
                          if (_controller != null && _config != null) {
                            _controller!.loadRequest(Uri.parse(_config!.mainUrl));
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading && !_hasError)
              LoadingOverlay(progress: _loadingProgress),
          ],
        ),
      ),
    );
  }
}
