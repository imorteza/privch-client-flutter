# Private Channel

<p>
<a href='https://play.google.com/store/apps/details?id=xinlake.privch'>
<img alt='Get it on Google Play' height='100px' src='.lfs/google-play-badge-600x200.png'/></a>
</p>

A modern VPN client built with Flutter supports Android and Windows but does not provide international communication services. The app is also available on [Google Play](https://play.google.com/store/apps/details?id=xinlake.privch).

# Build
### Requirements
* **Git**. Make sure `git.exe` can be called by other build systems
* **Flutter SDK**. Make sure `flutter doctor -v` doesn't prompt issues after [installing the Flutter SDK](https://docs.flutter.dev/get-started/install/windows), 
* **Android Studio**, only required to build Android APK.
    * Android SDK Command-line Tools (last)
    * CMake
    * NDK
* **Visual Studio 2022**, only required to build Windows (native) application.
    * "Desktop development with C++" workload
    * C++ CMake tools for Windows
    * [Optional] Windows 10 SDK v10.0.20348.0

### Clean
```
C:\privch\application> flutter clean
```

### Build PrivCh Android APK
* Option 1, using Flutter commands.
```
C:\privch\application> flutter pub get
C:\privch\application> flutter build apk
```

* Option 2, using Android Studio.

Run the `flutter pub get` command then open `<SOURCE-CODE>/application/android` with Android Studio.

### Build PrivCh Windows Application
* Option 1, using Flutter commands.
```
C:\privch\application> flutter pub get
C:\privch\application> flutter build windows
```

* Option 2, using Visual Studio.

Run the `flutter pub get` command, Open Visual Studio select "Open a local folder" then select `<SOURCE-CODE>/application/windows`.

# Screen
### Android
<p>
<table>
    <tr>
        <td><img src=".lfs/screen/al-auto3.png"/></td>
        <td><img src=".lfs/screen/al-setting.png"/></td>
        <td><img src=".lfs/screen/al-about.png"/></td>
    </tr>
    <tr>
        <td><img src=".lfs/screen/ad-empty.png"/></td>
        <td><img src=".lfs/screen/ad-list2.png"/></td>
        <td><img src=".lfs/screen/ad-detail.png"/></td>
    </tr>
</table>
</p>

### Windows
<p>
<table>
    <tr>
        <td><img src=".lfs/screen/wl-1600x900-empty.png"/></td>
        <td><img src=".lfs/screen/wl-1600x900-encrypt.png"/></td>
    </tr>
    <tr>
        <td><img src=".lfs/screen/wd-1600x900-list2.png"/></td>
        <td><img src=".lfs/screen/wd-1600x900-about.png"/></td>
    </tr>
</table>
</p>
