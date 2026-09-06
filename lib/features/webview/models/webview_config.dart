class WebViewConfig {
  final String mainUrl;
  final String allowedHost;

  const WebViewConfig({
    required this.mainUrl,
    required this.allowedHost,
  });

  WebViewConfig copyWith({
    String? mainUrl,
    String? allowedHost,
  }) {
    return WebViewConfig(
      mainUrl: mainUrl ?? this.mainUrl,
      allowedHost: allowedHost ?? this.allowedHost,
    );
  }

  @override
  String toString() => 'WebViewConfig(mainUrl: $mainUrl, allowedHost: $allowedHost)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebViewConfig &&
        other.mainUrl == mainUrl &&
        other.allowedHost == allowedHost;
  }

  @override
  int get hashCode => Object.hash(mainUrl, allowedHost);
}
