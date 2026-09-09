import 'package:webview_domain_lock/features/cast/models/detected_subtitle.dart';

class DetectedVideo {
  final String url;
  final String title;
  final List<DetectedSubtitle> subtitles;
  final Map<String, String> headers;
  final String? quality;

  const DetectedVideo({
    required this.url,
    required this.title,
    this.subtitles = const [],
    this.headers = const {},
    this.quality,
  });

  bool get isHls =>
      url.toLowerCase().contains('.m3u8') ||
      url.toLowerCase().contains('/hls/');

  bool get isMp4 => url.toLowerCase().contains('.mp4');

  DetectedVideo copyWith({
    String? url,
    String? title,
    List<DetectedSubtitle>? subtitles,
    Map<String, String>? headers,
    String? quality,
  }) {
    return DetectedVideo(
      url: url ?? this.url,
      title: title ?? this.title,
      subtitles: subtitles ?? this.subtitles,
      headers: headers ?? this.headers,
      quality: quality ?? this.quality,
    );
  }

  factory DetectedVideo.fromJson(Map<String, dynamic> json) {
    final rawSubs = json['subtitles'] as List<dynamic>? ?? [];
    return DetectedVideo(
      url: json['videoUrl'] as String? ?? json['url'] as String? ?? '',
      title: json['title'] as String? ?? 'Web Video',
      subtitles: rawSubs
          .map((e) => DetectedSubtitle.fromJson(e as Map<String, dynamic>))
          .toList(),
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      quality: json['quality'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectedVideo &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() =>
      'DetectedVideo(title: $title, url: $url, subtitles: ${subtitles.length})';
}
