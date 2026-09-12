class AppUpdateInfo {
  final String version;
  final int versionCode;
  final String releaseNotes;
  final String mobileApkUrl;
  final String tvApkUrl;

  const AppUpdateInfo({
    required this.version,
    required this.versionCode,
    required this.releaseNotes,
    required this.mobileApkUrl,
    required this.tvApkUrl,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['latest_version']?.toString() ?? json['version']?.toString() ?? '',
      versionCode: int.tryParse(json['latest_version_code']?.toString() ?? json['version_code']?.toString() ?? '0') ?? 0,
      releaseNotes: json['release_notes']?.toString() ?? 'Pembaruan aplikasi IDLIX terbaru tersedia.',
      mobileApkUrl: json['mobile_apk_url']?.toString() ?? 'https://github.com/Asadaaaaa/IDLIX-App/releases/latest/download/IDLIX.apk',
      tvApkUrl: json['tv_apk_url']?.toString() ?? 'https://github.com/Asadaaaaa/IDLIX-App/releases/latest/download/IDLIX-TV.apk',
    );
  }
}
