import 'dart:typed_data';

enum XinUiMode { light, dark, system, custom }

enum XinAndroidAppDir {
  /// Same as the path returned by the getCacheDir()
  internalCache,

  /// Same as the path returned by the getFilesDir()
  internalFiles,

  /// Same as the path returned by the getExternalCacheDir()
  externalCache,

  /// Same as the path returned by the getExternalFilesDir(null)
  externalFiles,
}

class XinVersionInfo {
  final String version;
  final int? buildNumber;

  final String? appName;
  final String? packageName;
  final DateTime? lastUpdatedTime;

  XinVersionInfo({
    required this.version,
    this.buildNumber,
    this.appName,
    this.packageName,
    int? lastUpdatedMsUtc,
  }) : lastUpdatedTime = lastUpdatedMsUtc != null
            ? DateTime.utc(1970, 1, 1, 0, 0, 0, lastUpdatedMsUtc, 0).toLocal()
            : null;
}

class XinFile {
  final String name;
  final String? path;
  final int length;
  final Uint8List? data;
  final DateTime? modifiedDate;

  XinFile(this.name, this.path, this.length, this.data, int? modifiedMsUtc)
      : modifiedDate =
            modifiedMsUtc != null ? DateTime.utc(1970, 1, 1, 0, 0, 0, modifiedMsUtc, 0).toLocal() : null;
}
