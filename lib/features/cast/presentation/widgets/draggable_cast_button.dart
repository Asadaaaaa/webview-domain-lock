import 'package:flutter/material.dart';
import 'package:webview_domain_lock/features/cast/models/detected_video.dart';
import 'package:webview_domain_lock/features/cast/presentation/widgets/cast_modal_bottom_sheet.dart';
import 'package:webview_domain_lock/features/cast/services/cast_manager.dart';
import 'package:webview_domain_lock/features/cast/services/video_detector_service.dart';

class DraggableCastButton extends StatefulWidget {
  final VideoDetectorService videoDetectorService;
  final CastManager castManager;

  const DraggableCastButton({
    super.key,
    required this.videoDetectorService,
    required this.castManager,
  });

  @override
  State<DraggableCastButton> createState() => _DraggableCastButtonState();
}

class _DraggableCastButtonState extends State<DraggableCastButton> {
  Offset? _position;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<DetectedVideo>>(
      valueListenable: widget.videoDetectorService.detectedVideosNotifier,
      builder: (context, videos, _) {
        if (videos.isEmpty || widget.castManager.isCasting) {
          return const SizedBox.shrink();
        }

        final size = MediaQuery.of(context).size;
        final buttonSize = 56.0;

        // Inisialisasi posisi awal di kanan bawah jika belum diset
        _position ??= Offset(
          size.width - buttonSize - 20,
          size.height - buttonSize - 40,
        );

        // Batasi kursor agar tidak keluar dari batas layar (clamping)
        final double minX = 10.0;
        final double maxX = (size.width - buttonSize - 10.0).clamp(minX, double.infinity);
        final double minY = 30.0;
        final double maxY = (size.height - buttonSize - 20.0).clamp(minY, double.infinity);

        final safeDx = _position!.dx.clamp(minX, maxX);
        final safeDy = _position!.dy.clamp(minY, maxY);
        final safePos = Offset(safeDx, safeDy);

        return Positioned(
          left: safePos.dx,
          top: safePos.dy,
          child: GestureDetector(
            onPanStart: (_) {
              setState(() {
                _isDragging = true;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(
                  safePos.dx + details.delta.dx,
                  safePos.dy + details.delta.dy,
                );
              });
            },
            onPanEnd: (_) {
              setState(() {
                _isDragging = false;
              });
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  CastModalBottomSheet.show(
                    context: context,
                    videoDetectorService: widget.videoDetectorService,
                    castManager: widget.castManager,
                  );
                },
                borderRadius: BorderRadius.circular(buttonSize / 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1E27), Color(0xFFB8050D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isDragging
                            ? const Color(0xFFE50914).withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.45),
                        blurRadius: _isDragging ? 16 : 8,
                        spreadRadius: _isDragging ? 3 : 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.cast,
                        color: Colors.white,
                        size: 26,
                      ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '${videos.length}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
