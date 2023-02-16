#include <windows.h>
#include <VersionHelpers.h>
#include <dwmapi.h>

#include <tchar.h>
#include <filesystem>

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include "_utils.h"

#pragma warning(disable : 4293)
#pragma comment(lib, "Version")
#pragma comment(lib, "Dwmapi.lib")

bool _setDarkMode(HWND hwnd, BOOL isDarkMode);


void setNativeUiMode(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    int isDarkMode = -1;
    LONGLONG darkColor;  // not used yet
    LONGLONG lightColor; // not used yet

    // check arguments
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto modeKey = arguments->find(flutter::EncodableValue("modeIndex"));
        if (modeKey != arguments->end() && !modeKey->second.IsNull()) {
            // light = 0, dark, system, custom
            int mode = std::get<int>(modeKey->second);
            switch (mode)
            {
            case 0:
                isDarkMode = 0;
                break;
            case 1:
                isDarkMode = 1;
                break;
            default:
                // not supported
                break;
            }
        }

        auto darkColorKey = arguments->find(flutter::EncodableValue("darkColor"));
        if (darkColorKey != arguments->end() && !darkColorKey->second.IsNull()) {
            darkColor = std::get<LONGLONG>(darkColorKey->second);
        }

        auto lightColorKey = arguments->find(flutter::EncodableValue("lightColor"));
        if (lightColorKey != arguments->end() && !lightColorKey->second.IsNull()) {
            lightColor = std::get<LONGLONG>(lightColorKey->second);
        }
    }

    if (isDarkMode < 0) {
        // ignored
        result->Success(flutter::EncodableValue(0));
        return;
    }

    HWND _hwnd = GetActiveWindow();
    BOOL _ok = _setDarkMode(_hwnd, isDarkMode);

    // send results
    result->Success(flutter::EncodableValue(_ok));
}

void getAppDir(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    // std::filesystem::current_path is the path of the working directory
    TCHAR szPath[MAX_PATH];
    if (!GetModuleFileName(NULL, szPath, MAX_PATH)) {
        result->Error("GetModuleFileName");
        return;
    }

    std::filesystem::path appPath = Utf8FromUtf16(szPath);
    std::string appDir = appPath.parent_path().string();
    result->Success(flutter::EncodableValue(appDir.c_str()));
}

void getAppVersion(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    bool flutterStyle = false;

    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto flutterStyleKey = arguments->find(flutter::EncodableValue("flutterStyle"));
        if (flutterStyleKey != arguments->end() && !flutterStyleKey->second.IsNull()) {
            flutterStyle = std::get<bool>(flutterStyleKey->second);
        }
    }

    TCHAR szPath[MAX_PATH];
    if (!GetModuleFileName(NULL, szPath, MAX_PATH)) {
        result->Error("GetModuleFileName");
        return;
    }

    char version[32];
    int buildNumber = 0;

    DWORD verHandle = 0;
    DWORD verSize = GetFileVersionInfoSize(szPath, &verHandle);
    if (verSize != NULL) {

        LPSTR verData = new char[verSize];
        if (GetFileVersionInfo(szPath, verHandle, verSize, verData)) {

            UINT   size = 0;
            LPBYTE lpBuffer = NULL;
            if (VerQueryValue(verData, L"\\", (VOID FAR * FAR*) & lpBuffer, &size)) {
                if (size > 0) {
                    VS_FIXEDFILEINFO* verInfo = (VS_FIXEDFILEINFO*)lpBuffer;

                    if (flutterStyle) {
                        int length = sprintf_s(version, "%hu.%hu.%hu",
                            HIWORD(verInfo->dwProductVersionMS),
                            LOWORD(verInfo->dwProductVersionMS),
                            HIWORD(verInfo->dwProductVersionLS)
                        );

                        buildNumber = LOWORD(verInfo->dwProductVersionLS);
                        version[length] = 0;
                    } else {
                        int length = sprintf_s(version, "%hu.%hu.%hu.%hu",
                            HIWORD(verInfo->dwProductVersionMS),
                            LOWORD(verInfo->dwProductVersionMS),
                            HIWORD(verInfo->dwProductVersionLS),
                            LOWORD(verInfo->dwProductVersionLS)
                        );

                        version[length] = 0;
                    }
                }
            }
        }

        delete[] verData;
    }

    LONG64 modified = getFileModified(szPath);

    flutter::EncodableMap map;
    map[flutter::EncodableValue("version")] = version;
    map[flutter::EncodableValue("build-number")] = buildNumber;
    map[flutter::EncodableValue("updated-utc")] = modified;
    result->Success(flutter::EncodableValue(map));
}


// Internal
// https://stackoverflow.com/questions/57124243/winforms-dark-title-bar-on-windows-10
bool _setDarkMode(HWND hwnd, BOOL isDarkMode) {
    if (IsWindows10OrGreater()) {
        DWORD attribute = IsWindowsVersionOrGreater(
            HIBYTE(_WIN32_WINNT_WINTHRESHOLD), LOBYTE(_WIN32_WINNT_WINTHRESHOLD), 18985)
            ? DWMWINDOWATTRIBUTE::DWMWA_USE_IMMERSIVE_DARK_MODE
            : 19; // DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1;

        HRESULT hResult = DwmSetWindowAttribute(hwnd,
            attribute, &isDarkMode, sizeof(isDarkMode));

        return SUCCEEDED(hResult);
    }

    return false;
}
