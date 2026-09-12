import 'package:flutter/material.dart';
import 'package:webview_domain_lock/features/tv/services/tv_remote_controller.dart';

class TvVirtualCursor extends StatelessWidget {
  final TvRemoteController remoteController;

  const TvVirtualCursor({
    super.key,
    required this.remoteController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: remoteController.isCursorVisibleNotifier,
      builder: (context, isVisible, _) {
        if (!isVisible) return const SizedBox.shrink();

        return ValueListenableBuilder<Offset>(
          valueListenable: remoteController.cursorPositionNotifier,
          builder: (context, pos, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: remoteController.isClickingNotifier,
              builder: (context, isClicking, _) {
                return Positioned(
                  left: pos.dx - 14,
                  top: pos.dy - 14,
                  child: IgnorePointer(
                    child: AnimatedScale(
                      scale: isClicking ? 0.75 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isClicking
                              ? Colors.amberAccent.withValues(alpha: 0.9)
                              : Colors.blueAccent.withValues(alpha: 0.75),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
