import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_domain_lock/core/services/storage_service.dart';
import 'package:webview_domain_lock/features/cast/models/detected_video.dart';
import 'package:webview_domain_lock/features/cast/presentation/widgets/cast_button.dart';
import 'package:webview_domain_lock/features/cast/presentation/widgets/cast_control_bar.dart';
import 'package:webview_domain_lock/features/cast/presentation/widgets/cast_modal_bottom_sheet.dart';
import 'package:webview_domain_lock/features/cast/services/cast_manager.dart';
import 'package:webview_domain_lock/features/cast/services/video_detector_service.dart';
import 'package:webview_domain_lock/features/tv/presentation/widgets/tv_quick_menu.dart';
import 'package:webview_domain_lock/features/tv/presentation/widgets/tv_virtual_cursor.dart';
import 'package:webview_domain_lock/features/tv/services/tv_remote_controller.dart';
import 'package:webview_domain_lock/features/webview/models/webview_config.dart';
import 'package:webview_domain_lock/features/webview/presentation/widgets/loading_overlay.dart';
import 'package:webview_domain_lock/core/services/remote_config_service.dart';
import 'package:webview_domain_lock/features/webview/services/webview_navigation_service.dart';
import 'package:dart_cast/dart_cast.dart';

class WebViewPage extends StatefulWidget {
  final StorageService storageService;
  final RemoteConfigService remoteConfigService;
  final WebViewConfig initialConfig;

  const WebViewPage({
    super.key,
    required this.storageService,
    required this.remoteConfigService,
    required this.initialConfig,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewNavigationService _navigationService;
  late final VideoDetectorService _videoDetectorService;
  late final CastManager _castManager;
  late final TvRemoteController _tvRemoteController;

  WebViewController? _controller;
  WebViewConfig? _config;

  bool _isLoading = true;
  int _loadingProgress = 0;
  bool _hasError = false;
  String? _errorMessage;

  bool _isTvMenuOpen = false;
  Widget? _fullscreenCustomWidget;
  void Function()? _onHideCustomWidget;

  @override
  void initState() {
    super.initState();
    _navigationService = WebViewNavigationService();
    _videoDetectorService = VideoDetectorService();
    _castManager = CastManager();
    _castManager.init();
    _config = widget.initialConfig;

    _tvRemoteController = TvRemoteController(
      getController: () => _controller!,
      onToggleMenu: () {
        setState(() {
          _isTvMenuOpen = !_isTvMenuOpen;
        });
      },
      onBack: () => _handleBackPress(),
      onMediaPlayPause: () {
        if (_castManager.isCasting) {
          final isPlaying =
              _castManager.sessionStateNotifier.value == SessionState.playing;
          if (isPlaying) {
            _castManager.pause();
          } else {
            _castManager.play();
          }
        } else {
          _controller?.runJavaScript('''
            (function() {
              var videos = document.querySelectorAll('video');
              if (videos.length > 0) {
                var v = videos[0];
                if (v.paused) v.play(); else v.pause();
              }
            })();
          ''').catchError((_) {});
        }
      },
      onMediaForward: () {
        if (_castManager.isCasting) {
          final cur = _castManager.positionNotifier.value;
          _castManager.seek(cur + const Duration(seconds: 10));
        } else {
          _controller?.runJavaScript('''
            (function() {
              var videos = document.querySelectorAll('video');
              if (videos.length > 0) videos[0].currentTime += 10;
            })();
          ''').catchError((_) {});
        }
      },
      onMediaRewind: () {
        if (_castManager.isCasting) {
          final cur = _castManager.positionNotifier.value;
          final newPos = cur - const Duration(seconds: 10);
          _castManager.seek(newPos.isNegative ? Duration.zero : newPos);
        } else {
          _controller?.runJavaScript('''
            (function() {
              var videos = document.querySelectorAll('video');
              if (videos.length > 0) videos[0].currentTime = Math.max(0, videos[0].currentTime - 10);
            })();
          ''').catchError((_) {});
        }
      },
    );
    _tvRemoteController.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebView();
      _checkRemoteConfigUpdate();
    });
  }

  @override
  void dispose() {
    _tvRemoteController.dispose();
    _castManager.stopDiscovery();
    super.dispose();
  }

  /// Memeriksa pembaruan URL domain dari GitHub raw secara berkala atau saat diminta pengguna
  Future<void> _checkRemoteConfigUpdate({bool showFeedback = false}) async {
    try {
      final latest = await widget.remoteConfigService.fetchLatestConfig();
      if (!mounted) return;

      if (latest.mainUrl != _config?.mainUrl || latest.allowedHost != _config?.allowedHost) {
        setState(() {
          _config = latest;
          _hasError = false;
          _errorMessage = null;
          _isLoading = true;
        });

        if (_controller != null) {
          await _controller!.loadRequest(Uri.parse(latest.mainUrl));
        } else {
          _initializeWebView();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Domain IDLIX diperbarui: ${latest.mainUrl}'),
              backgroundColor: Colors.teal,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Domain IDLIX sudah yang terbaru (${latest.mainUrl})'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memeriksa pembaruan domain IDLIX dari GitHub.'),
            duration: Duration(seconds: 2),
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
      androidController.setMediaPlaybackRequiresUserGesture(false);
      androidController.setCustomWidgetCallbacks(
        onShowCustomWidget: (Widget widget, OnHideCustomWidgetCallback callback) {
          setState(() {
            _fullscreenCustomWidget = widget;
            _onHideCustomWidget = callback;
          });
        },
        onHideCustomWidget: () {
          setState(() {
            _fullscreenCustomWidget = null;
            _onHideCustomWidget = null;
          });
        },
      );
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'VideoDetectorChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _videoDetectorService.handleMessage(message.message);
        },
      )
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
            _videoDetectorService.clear();
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              // Injeksi JS untuk mencegah popup window.open dan target="_blank"
              _preventPopupsAndNewWindows(controller);
              // Injeksi JS sniffer video & subtitle
              controller
                  .runJavaScript(VideoDetectorService.getInjectionScript())
                  .catchError((_) {});
              // Terapkan zoom default untuk layar TV
              controller
                  .runJavaScript(
                    "document.body.style.zoom = '${_tvRemoteController.textScaleNotifier.value}';",
                  )
                  .catchError((_) {});
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
            final eval = _navigationService.evaluateNavigation(
              request.url,
              allowedHost,
              isMainFrame: request.isMainFrame,
            );

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
    if (_fullscreenCustomWidget != null) {
      _onHideCustomWidget?.call();
      setState(() {
        _fullscreenCustomWidget = null;
      });
      return;
    }
    if (_isTvMenuOpen) {
      setState(() {
        _isTvMenuOpen = false;
      });
      return;
    }
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
    _tvRemoteController.updateScreenSize(MediaQuery.of(context).size);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        appBar: _fullscreenCustomWidget != null
            ? null
            : AppBar(
                title: Text(
                  _config?.allowedHost ?? 'WebView Domain Lock',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_remote),
                    tooltip: 'TV Remote Menu',
                    onPressed: () {
                      setState(() {
                        _isTvMenuOpen = !_isTvMenuOpen;
                      });
                    },
                  ),
                  CastButton(
                    videoDetectorService: _videoDetectorService,
                    castManager: _castManager,
                  ),
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
                    icon: const Icon(Icons.sync),
                    tooltip: 'Cek Update Domain',
                    onPressed: () => _checkRemoteConfigUpdate(showFeedback: true),
                  ),
                ],
              ),
        bottomNavigationBar: _fullscreenCustomWidget != null
            ? null
            : CastControlBar(
                castManager: _castManager,
                videoDetectorService: _videoDetectorService,
              ),
        floatingActionButton: _fullscreenCustomWidget != null
            ? null
            : ValueListenableBuilder<List<DetectedVideo>>(
                valueListenable: _videoDetectorService.detectedVideosNotifier,
                builder: (context, videos, _) {
                  if (videos.isEmpty || _castManager.isCasting) {
                    return const SizedBox.shrink();
                  }
                  return FloatingActionButton.extended(
                    onPressed: () {
                      CastModalBottomSheet.show(
                        context: context,
                        videoDetectorService: _videoDetectorService,
                        castManager: _castManager,
                      );
                    },
                    icon: const Icon(Icons.cast),
                    label: Text('Cast Video (${videos.length})'),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  );
                },
              ),
        body: Stack(
          children: [
            // 1. Fullscreen Custom HTML5 Video Widget jika dipicu oleh player website
            if (_fullscreenCustomWidget != null)
              Positioned.fill(child: _fullscreenCustomWidget!),

            // 2. WebView Biasa
            if (_controller != null && !_hasError && _fullscreenCustomWidget == null)
              WebViewWidget(controller: _controller!),

            // 3. Error State
            if (_hasError && _fullscreenCustomWidget == null)
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

            // 4. Loading Overlay
            if (_isLoading && !_hasError && _fullscreenCustomWidget == null)
              LoadingOverlay(progress: _loadingProgress),

            // 5. Kursor Virtual Mouse untuk Remote TV
            if (_fullscreenCustomWidget == null)
              TvVirtualCursor(remoteController: _tvRemoteController),

            // 6. Tombol Akses Cepat Menu Remote TV di Layar
            if (_fullscreenCustomWidget == null)
              Positioned(
                top: 12,
                left: 12,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isTvMenuOpen = !_isTvMenuOpen;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.settings_remote, color: Colors.blueAccent, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'TV Remote (Menu)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 7. Menu Cepat TV Overlay
            if (_isTvMenuOpen)
              Positioned.fill(
                child: TvQuickMenu(
                  remoteController: _tvRemoteController,
                  getController: () => _controller!,
                  videoDetectorService: _videoDetectorService,
                  castManager: _castManager,
                  onOpenSettings: () => _checkRemoteConfigUpdate(showFeedback: true),
                  onClose: () {
                    setState(() {
                      _isTvMenuOpen = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
