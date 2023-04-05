# Private Channel

<p>
<a href='https://play.google.com/store/apps/details?id=xinlake.privch'>
<img alt='Get it on Google Play' height='100px' src='.lfs/google-play-badge-600x200.png'/>
</a>
</p>

PrivCh is a modern VPN client built with Flutter that supports Android and Windows, but does not offer international communication services. The app is also available on [Google Play](https://play.google.com/store/apps/details?id=xinlake.privch).

| Directory | Description |
|---------|---------|
| [application](./application/) | The privch cross-platform VPN client app |
| [xinlake-responsive](./xinlake-responsive/) | A Flutter package that contains widgets for responsive design |
| [xinlake-text](./xinlake-text/) | A Flutter package that supports text processing |
| [xinlake-qrcode](./xinlake-qrcode/) | A Flutter plugin that read barcode from images, cameras, screens |
| [xinlake-platform](./xinlake-platform/) | A Flutter plugin that contains platform-side implementations to help Flutter apps interact with the system |
| [window-interface](./window-interface/) | A Flutter plugin that controls the native window of your flutter app on Windows |


# Build
### Requirements
* [**Git**](https://git-scm.com). Make sure `git.exe` can be called by other build systems
* [**Flutter SDK**](https://flutter.dev). Make sure `flutter doctor -v` doesn't prompt issues after [installing the Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
* [**Rust**](https://www.rust-lang.org), only required to build Android APK. After [installing Rust](https://www.rust-lang.org/tools/install), you also need to install Android targets.
    * `rustup target add armv7-linux-androideabi aarch64-linux-android`
    * [Optional] `rustup target add i686-linux-android x86_64-linux-android`
* [**Python**](https://www.python.org), only required to build Android APK.
* [**Android Studio**](https://developer.android.com/studio), only required to build Android APK.
    * Android SDK Command-line Tools (last)
    * CMake
    * NDK
* [**Visual Studio 2022**](https://visualstudio.microsoft.com), only required to build Windows (native) application.
    * "Desktop development with C++" workload
    * C++ CMake tools for Windows
    * [Optional] Windows 10 SDK v10.0.20348.0

### Clean
```powershell
C:\privch\application> flutter clean
```

### Build PrivCh Android APK
* Option 1, using Flutter commands.
```powershell
C:\privch\application> flutter pub get

# This step is only required when doing a fresh build
C:\privch\application\android> .\gradlew.bat generateReleaseSources

C:\privch\application> flutter build apk
```

* Option 2, using Android Studio.

Run the `flutter pub get` command then open `<SOURCE-CODE>/application/android` with Android Studio. For fresh builds you need to execute `Build` -> `Run Generate Sources Gradle Tasks` before building APK

### Build PrivCh Windows Application
* Option 1, using Flutter commands.
```powershell
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
        <td><img src=".lfs/screen/life-2.jpg"/></td>
        <td><img src=".lfs/screen/life-3.jpg"/></td>
    </tr>
    <tr>
        <td colspan=2><img src=".lfs/screen/life-1.jpg"/></td>
    </tr>
</table>
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
