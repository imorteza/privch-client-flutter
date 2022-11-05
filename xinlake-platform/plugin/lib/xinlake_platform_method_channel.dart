import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'types.dart';
import 'xinlake_platform_interface.dart';

/// An implementation of [XinlakePlatformInterface] that uses method channels.
class MethodChannelXinlakePlatform extends XinlakePlatformInterface {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xinlake_platform');

  @override
  Future<List<XinFile>?> pickFile(
    bool multiSelection,
    String fileTypes,
    // android
    XinAndroidAppDir? cacheDir,
    bool cacheOverwrite,
    // windows
    String? openPath,
    String? defaultPath,
    String? fileDescription,
  ) async {
    try {
      final list = await methodChannel.invokeListMethod('pickFile', {
        'multiSelection': multiSelection,
        'fileTypes': fileTypes,
        'cacheDirIndex': cacheDir?.index,
        'cacheOverwrite': cacheOverwrite,
        'openPath': openPath,
        'defaultPath': defaultPath,
        'fileDescription': fileDescription,
      });

      if ((list != null)) {
        return list
            .map((map) => XinFile(
                  map['name'],
                  map['path'],
                  map['length'],
                  map['data'],
                  map['modified-ms'],
                ))
            .toList();
      }
    } catch (error) {
      // ignored
    }

    return null;
  }

  @override
  Future<void> setUiMode(
    XinUiMode mode,
    int darkColor,
    int lightColor,
    int animateMs,
  ) async {
    try {
      return await methodChannel.invokeMethod('setUiMode', {
        'modeIndex': mode.index,
        'darkColor': darkColor,
        'lightColor': lightColor,
        'animateMs': animateMs,
      });
    } catch (error) {
      // ignored
    }
  }

  @override
  Future<String?> getAppDir(XinAndroidAppDir? androidAppDir) async {
    try {
      return await methodChannel.invokeMethod('getAppDir', {
        'appDirIndex': androidAppDir?.index,
      });
    } catch (error) {
      return null;
    }
  }

  @override
  Future<XinVersionInfo?> getAppVersion(bool flutterStyle) async {
    try {
      final map = await methodChannel.invokeMapMethod<String, dynamic>('getAppVersion', {
        'flutterStyle': flutterStyle,
      });
      if (map != null) {
        return XinVersionInfo(
          version: map['version'],
          buildNumber: map['build-number'],
          packageName: map['package-name'],
          lastUpdatedMsUtc: map['updated-utc'],
        );
      }
    } catch (error) {
      // ignored
    }

    return null;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
