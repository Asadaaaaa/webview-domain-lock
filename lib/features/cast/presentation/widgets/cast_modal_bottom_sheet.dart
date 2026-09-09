import 'package:dart_cast/dart_cast.dart';
import 'package:flutter/material.dart';
import 'package:webview_domain_lock/features/cast/models/detected_subtitle.dart';
import 'package:webview_domain_lock/features/cast/models/detected_video.dart';
import 'package:webview_domain_lock/features/cast/services/cast_manager.dart';
import 'package:webview_domain_lock/features/cast/services/video_detector_service.dart';

class CastModalBottomSheet extends StatefulWidget {
  final VideoDetectorService videoDetectorService;
  final CastManager castManager;

  const CastModalBottomSheet({
    super.key,
    required this.videoDetectorService,
    required this.castManager,
  });

  static Future<void> show({
    required BuildContext context,
    required VideoDetectorService videoDetectorService,
    required CastManager castManager,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CastModalBottomSheet(
        videoDetectorService: videoDetectorService,
        castManager: castManager,
      ),
    );
  }

  @override
  State<CastModalBottomSheet> createState() => _CastModalBottomSheetState();
}

class _CastModalBottomSheetState extends State<CastModalBottomSheet> {
  DetectedVideo? _selectedVideo;
  DetectedSubtitle? _selectedSubtitle;
  bool _isNoneSubtitle = false;

  @override
  void initState() {
    super.initState();
    // Default video selection
    final videos = widget.videoDetectorService.detectedVideos;
    if (videos.isNotEmpty) {
      _selectedVideo = widget.castManager.activeVideoNotifier.value ?? videos.first;
      _initDefaultSubtitle(_selectedVideo!);
    }

    // Auto-start discovery saat bottom sheet dibuka
    widget.castManager.startDiscovery();
  }

  void _initDefaultSubtitle(DetectedVideo video) {
    if (video.subtitles.isNotEmpty) {
      // Prioritaskan subtitle bahasa Indonesia jika ada
      final idSub = video.subtitles.firstWhere(
        (s) =>
            s.lang.toLowerCase() == 'id' ||
            s.label.toLowerCase().contains('indonesia') ||
            s.url.toLowerCase().contains('indonesia'),
        orElse: () => video.subtitles.first,
      );
      _selectedSubtitle = idSub;
      _isNoneSubtitle = false;
    } else {
      _selectedSubtitle = null;
      _isNoneSubtitle = true;
    }
  }

  void _showManualInputDialog() {
    final videoUrlController = TextEditingController();
    final subUrlController = TextEditingController();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Input Video Manual'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Video (Opsional)',
                  hintText: 'Moana (2026)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Video Stream URL (*.m3u8 / *.mp4)',
                  hintText: 'https://.../master.m3u8',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subUrlController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle URL (*.vtt / *.srt)',
                  hintText: 'https://.../indonesian.vtt',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final vUrl = videoUrlController.text.trim();
              if (vUrl.isNotEmpty) {
                widget.videoDetectorService.addManualVideo(
                  url: vUrl,
                  title: titleController.text.trim().isNotEmpty
                      ? titleController.text.trim()
                      : 'Manual Stream',
                  subtitleUrl: subUrlController.text.trim().isNotEmpty
                      ? subUrlController.text.trim()
                      : null,
                );
                final updated = widget.videoDetectorService.detectedVideos;
                if (updated.isNotEmpty) {
                  setState(() {
                    _selectedVideo = updated.last;
                    _initDefaultSubtitle(_selectedVideo!);
                  });
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text('Tambahkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _startCast(CastDevice device) async {
    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih video terlebih dahulu')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menghubungkan ke ${device.name}...'),
          duration: const Duration(seconds: 2),
        ),
      );

      final subToUse = _isNoneSubtitle ? null : _selectedSubtitle;

      await widget.castManager.castVideo(
        video: _selectedVideo!,
        subtitle: subToUse,
        targetDevice: device,
      );

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sedang memutar pada ${device.name} ${subToUse != null ? "dengan Subtitle (${subToUse.label})" : ""}',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan Cast: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cast, color: Colors.blueAccent),
                const SizedBox(width: 8),
                const Text(
                  'Cast Video & Subtitle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Bagian Kontrol Jika Sedang Casting
                _buildActiveCastController(),

                // 2. Bagian Video Terdeteksi
                _buildVideoSelectionSection(theme),
                const SizedBox(height: 16),

                // 3. Bagian Subtitle
                if (_selectedVideo != null) ...[
                  _buildSubtitleSelectionSection(theme),
                  const SizedBox(height: 16),
                ],

                // 4. Bagian Perangkat Cast (Discovery)
                _buildDeviceDiscoverySection(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCastController() {
    return ValueListenableBuilder<CastDevice?>(
      valueListenable: widget.castManager.activeDeviceNotifier,
      builder: (context, activeDevice, _) {
        if (activeDevice == null) return const SizedBox.shrink();

        return ValueListenableBuilder<SessionState>(
          valueListenable: widget.castManager.sessionStateNotifier,
          builder: (context, state, _) {
            if (state == SessionState.disconnected) {
              return const SizedBox.shrink();
            }

            final isPlaying = state == SessionState.playing;

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tv, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Casting ke: ${activeDevice.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          state.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar & Duration
                  ValueListenableBuilder<Duration>(
                    valueListenable: widget.castManager.positionNotifier,
                    builder: (context, pos, _) {
                      return ValueListenableBuilder<Duration>(
                        valueListenable: widget.castManager.durationNotifier,
                        builder: (context, dur, _) {
                          final maxSec = dur.inSeconds > 0
                              ? dur.inSeconds.toDouble()
                              : 100.0;
                          final curSec = pos.inSeconds
                              .toDouble()
                              .clamp(0.0, maxSec);

                          return Column(
                            children: [
                              Slider(
                                value: curSec,
                                max: maxSec,
                                activeColor: Colors.blueAccent,
                                inactiveColor: Colors.grey.shade700,
                                onChanged: (val) {
                                  widget.castManager
                                      .seek(Duration(seconds: val.toInt()));
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(pos),
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(dur),
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Playback Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        onPressed: () {
                          final cur = widget.castManager.positionNotifier.value;
                          final newPos = cur - const Duration(seconds: 10);
                          widget.castManager.seek(
                            newPos.isNegative ? Duration.zero : newPos,
                          );
                        },
                      ),
                      IconButton(
                        iconSize: 42,
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            widget.castManager.pause();
                          } else {
                            widget.castManager.play();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        onPressed: () {
                          final cur = widget.castManager.positionNotifier.value;
                          widget.castManager
                              .seek(cur + const Duration(seconds: 10));
                        },
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => widget.castManager.disconnect(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.stop, size: 16),
                        label: const Text('Stop Cast', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVideoSelectionSection(ThemeData theme) {
    return ValueListenableBuilder<List<DetectedVideo>>(
      valueListenable: widget.videoDetectorService.detectedVideosNotifier,
      builder: (context, videos, _) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.video_library, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Video Terdeteksi (${videos.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _showManualInputDialog,
                      icon: const Icon(Icons.add_link, size: 16),
                      label: const Text('Input URL', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const Divider(),
                if (videos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Icon(
                          Icons.ondemand_video,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Belum ada video terdeteksi di halaman ini.\nPutar video pada web atau masukkan URL manual.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: videos.map((v) {
                      final isSelected = _selectedVideo?.url == v.url;
                      final isHls = v.isHls;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.grey.shade50,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            width: isSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _selectedVideo = v;
                              _initDefaultSubtitle(v);
                            });
                          },
                          leading: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey.shade600,
                          ),
                          title: Text(
                            v.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.url,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isHls
                                          ? Colors.purple.shade100
                                          : Colors.teal.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isHls ? 'HLS (m3u8)' : 'MP4 Video',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isHls
                                            ? Colors.purple.shade900
                                            : Colors.teal.shade900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (v.subtitles.isNotEmpty)
                                    Text(
                                      '${v.subtitles.length} Subtitle tersedia',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitleSelectionSection(ThemeData theme) {
    final video = _selectedVideo!;
    final subs = video.subtitles;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.subtitles, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Subtitle (${subs.length} terdeteksi)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Tanpa Subtitle'),
                  selected: _isNoneSubtitle,
                  onSelected: (selected) {
                    setState(() {
                      _isNoneSubtitle = true;
                      _selectedSubtitle = null;
                    });
                    if (widget.castManager.isCasting) {
                      widget.castManager.setSubtitle(null);
                    }
                  },
                ),
                ...subs.map((s) {
                  final isSelected =
                      !_isNoneSubtitle && _selectedSubtitle?.url == s.url;
                  final isIndo = s.label.toLowerCase().contains('indo') ||
                      s.lang.toLowerCase() == 'id';

                  return ChoiceChip(
                    avatar: isIndo
                        ? const Text('🇮🇩', style: TextStyle(fontSize: 12))
                        : null,
                    label: Text('${s.label} (${s.url.endsWith(".vtt") ? "VTT" : "SRT"})'),
                    selected: isSelected,
                    selectedColor: Colors.blue.shade100,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSubtitle = s;
                        _isNoneSubtitle = false;
                      });
                      if (widget.castManager.isCasting) {
                        widget.castManager.setSubtitle(s);
                      }
                    },
                  );
                }),
              ],
            ),
            if (subs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Belum ada subtitle terdeteksi secara otomatis untuk stream ini.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceDiscoverySection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.devices, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Pilih Perangkat TV / Cast',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: widget.castManager.isScanningNotifier,
                  builder: (context, isScanning, _) {
                    if (isScanning) {
                      return const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      tooltip: 'Pindai Ulang',
                      onPressed: () => widget.castManager.startDiscovery(),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            ValueListenableBuilder<List<CastDevice>>(
              valueListenable: widget.castManager.devicesNotifier,
              builder: (context, devices, _) {
                if (devices.isEmpty) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: widget.castManager.isScanningNotifier,
                    builder: (context, isScanning, _) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.wifi_find,
                                size: 36,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isScanning
                                    ? 'Mencari perangkat Chromecast dan Smart TV (DLNA) di WiFi yang sama...'
                                    : 'Tidak ada perangkat ditemukan di jaringan WiFi ini.\nPastikan TV dan ponsel berada di jaringan WiFi yang sama.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return Column(
                  children: devices.map((d) {
                    final isChromecast = d.protocol == CastProtocol.chromecast;
                    final isDlna = d.protocol == CastProtocol.dlna;
                    final activeDevice =
                        widget.castManager.activeDeviceNotifier.value;
                    final isCurrentDevice = activeDevice?.id == d.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isCurrentDevice
                            ? Colors.green.shade50
                            : Colors.grey.shade50,
                        border: Border.all(
                          color: isCurrentDevice
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isChromecast
                              ? Colors.blue.shade100
                              : Colors.orange.shade100,
                          child: Icon(
                            isChromecast ? Icons.cast : Icons.tv,
                            color: isChromecast ? Colors.blue : Colors.orange,
                          ),
                        ),
                        title: Text(
                          d.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isChromecast
                                    ? 'Google Cast'
                                    : (isDlna ? 'Smart TV (DLNA)' : 'AirPlay'),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              d.address.address,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _startCast(d),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrentDevice
                                ? Colors.green.shade700
                                : theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          icon: Icon(
                            isCurrentDevice
                                ? Icons.check
                                : Icons.play_arrow,
                            size: 16,
                          ),
                          label: Text(
                            isCurrentDevice ? 'Casting' : 'Cast',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
