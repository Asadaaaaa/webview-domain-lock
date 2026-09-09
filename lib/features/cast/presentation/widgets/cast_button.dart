import 'package:flutter/material.dart';
import 'package:webview_domain_lock/features/cast/models/detected_video.dart';
import 'package:webview_domain_lock/features/cast/presentation/widgets/cast_modal_bottom_sheet.dart';
import 'package:webview_domain_lock/features/cast/services/cast_manager.dart';
import 'package:webview_domain_lock/features/cast/services/video_detector_service.dart';

class CastButton extends StatelessWidget {
  final VideoDetectorService videoDetectorService;
  final CastManager castManager;

  const CastButton({
    super.key,
    required this.videoDetectorService,
    required this.castManager,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ValueNotifier<bool>(castManager.isCasting),
      builder: (context, isCastingVal, child) {
        return ValueListenableBuilder<List<DetectedVideo>>(
          valueListenable: videoDetectorService.detectedVideosNotifier,
          builder: (context, videos, _) {
            final hasVideos = videos.isNotEmpty;
            final isCasting = castManager.isCasting;

            Widget icon = Icon(
              isCasting ? Icons.cast_connected : Icons.cast,
              color: isCasting
                  ? Colors.blue
                  : (hasVideos ? Colors.amber.shade700 : null),
            );

            if (hasVideos && !isCasting) {
              icon = Badge(
                label: Text(
                  videos.length.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.amber.shade800,
                child: icon,
              );
            }

            return IconButton(
              icon: icon,
              tooltip: isCasting
                  ? 'Active Cast Session'
                  : (hasVideos
                      ? '${videos.length} Video Terdeteksi - Siap Cast'
                      : 'Cast Video'),
              onPressed: () {
                CastModalBottomSheet.show(
                  context: context,
                  videoDetectorService: videoDetectorService,
                  castManager: castManager,
                );
              },
            );
          },
        );
      },
    );
  }
}
