import 'dart:async';

import 'package:flutter/services.dart';

/// Only supports Windows platform.
class WindowInterface {
  static const _eventChannel = EventChannel('window_interface_event');
  static const _methodChannel = MethodChannel('window_interface_method');

  // platform event subscription
  static const int _eventPlacement = 10;
  static StreamSubscription? _eventSubscription;

  /// Subscript to window events.
  /// * onPlacement: Callback when the window size or position has changed.
  static void startListen({void Function(WindowPlacement)? onPlacement}) {
    _eventSubscription ??= _eventChannel.receiveBroadcastStream().listen((data) {
      if (data is! Map || !data.containsKey('event')) {
        return;
      }

      // placement changed
      if (data['event'] == _eventPlacement) {
        try {
          final placement = WindowPlacement(
            x: data['x'],
            y: data['y'],
            width: data['width'],
            height: data['height'],
          );
          onPlacement?.call(placement);
        } catch (exception) {
          // ignored
        }
      }
    });

    _eventSubscription!.resume();
  }

  /// Cancel window events subscription
  static void stopListen() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  /// Get window position and size
  static Future<WindowPlacement?> getWindowPlacement() async {
    final map = await _methodChannel.invokeMapMethod<String, int>('getWindowPlacement');
    if (map != null) {
      return WindowPlacement(
        x: map['x']!,
        y: map['y']!,
        width: map['width']!,
        height: map['height']!,
      );
    }
    return null;
  }

  /// Set window position and size, effective immediately
  static Future<bool> setWindowPlacement(WindowPlacement placement) async {
    try {
      await _methodChannel.invokeMethod('setWindowPlacement', {
        'x': placement.x,
        'y': placement.y,
        'width': placement.width,
        'height': placement.height,
      });
      return true;
    } catch (exception) {
      // such as invalid arguments
      return false;
    }
  }

  /// Return True if the window is in full-screen mode, else False
  static Future<bool> getFullScreen() async {
    bool result = await _methodChannel.invokeMethod('getFullScreen');
    return result;
  }

  /// Set window full-screen mode, effective immediately
  static Future<void> setFullScreen(bool isFullScreen) async {
    await _methodChannel.invokeMethod('setFullScreen', {'isFullScreen': isFullScreen});
  }

  /// Toggle window full-screen mode, effective immediately
  static Future<void> toggleFullScreen() async {
    await _methodChannel.invokeMethod('toggleFullScreen');
  }

  /// Get window minimal size
  static Future<Size?> getWindowMinSize() async {
    final map = await _methodChannel.invokeMapMethod<String, int>('getWindowMinSize');
    if (map != null) {
      int width = map['width']!;
      int height = map['height']!;
      return Size(width.toDouble(), height.toDouble());
    }
    return null;
  }

  /// Set window minimal size, effective immediately
  static Future<bool> setWindowMinSize(int width, int height) async {
    try {
      await _methodChannel.invokeMethod('setWindowMinSize', {
        'width': width,
        'height': height,
      });
      return true;
    } catch (exception) {
      return false;
    }
  }

  /// Unset (don't limit) window minimal size
  static Future<void> resetWindowMinSize() async {
    await _methodChannel.invokeMethod('resetWindowMinSize');
  }

  /// Get window maximal size
  static Future<Size?> getWindowMaxSize() async {
    final map = await _methodChannel.invokeMapMethod<String, int>('getWindowMaxSize');
    if (map != null) {
      int width = map['width']!;
      int height = map['height']!;
      return Size(width.toDouble(), height.toDouble());
    }
    return null;
  }

  /// Set window maximal size, effective immediately
  static Future<bool> setWindowMaxSize(int width, int height) async {
    try {
      await _methodChannel.invokeMethod('setWindowMaxSize', {
        'width': width,
        'height': height,
      });
      return true;
    } catch (exception) {
      return false;
    }
  }

  /// Unset (don't limit) window maximal size
  static Future<void> resetWindowMaxSize() async {
    await _methodChannel.invokeMethod('resetWindowMaxSize');
  }

  /// Sets the window topmost mode, if set to True the window will appear sticky
  static Future<void> setStayOnTop(bool isStayOnTop) async {
    await _methodChannel.invokeMethod('setStayOnTop', {'isStayOnTop': isStayOnTop});
  }
}

// * 2022-03
class WindowPlacement {
  int x, y;
  int width, height;

  bool get isValid {
    return (width > 0) && (height > 0) && (x >= 0) && (y >= 0);
  }

  WindowPlacement({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
