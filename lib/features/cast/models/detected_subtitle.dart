class DetectedSubtitle {
  final String url;
  final String label;
  final String lang;

  const DetectedSubtitle({
    required this.url,
    required this.label,
    this.lang = 'auto',
  });

  factory DetectedSubtitle.fromJson(Map<String, dynamic> json) {
    return DetectedSubtitle(
      url: json['url'] as String? ?? '',
      label: json['label'] as String? ?? 'Subtitle',
      lang: json['lang'] as String? ?? 'auto',
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'label': label,
    'lang': lang,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectedSubtitle &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'DetectedSubtitle(label: $label, lang: $lang, url: $url)';
}
