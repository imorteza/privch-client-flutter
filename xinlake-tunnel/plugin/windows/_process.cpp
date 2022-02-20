#include <Windows.h>
#include <process.h>
#include <Tlhelp32.h>
#include <strsafe.h>

#include "resource.h"

#include <string>
#include <map>
#include <vector>
#include <fstream>
#include <filesystem>

const std::string privoxyDir = "binary\\privoxy-x64";
const std::string privoxyExe = "privoxy.exe";
const std::string privoxyConfig = "config.txt";
const std::vector<std::pair<int, std::string>> privoxyFiles{
    std::pair<int, std::string>{EXE_PRIVOXY,"privoxy.exe"},
};

const std::string ssDir = "binary\\shadowsocks-libev-x64";
const std::string ssLocalExe = "ss-local.exe";
const std::vector<std::pair<int, std::string>> ssFiles{
    std::pair<int, std::string>{DLL_LIBBLOOM,"libbloom.dll"},
    std::pair<int, std::string>{DLL_LIBCORK,"libcork.dll"},
    std::pair<int, std::string>{DLL_LIBEV_4,"libev-4.dll"},
    std::pair<int, std::string>{DLL_LIBGCC_S_SEH_1,"libgcc_s_seh-1.dll"},
    std::pair<int, std::string>{DLL_LIBIPSET,"libipset.dll"},
    std::pair<int, std::string>{DLL_LIBMBEDCRYPTO,"libmbedcrypto.dll"},
    std::pair<int, std::string>{DLL_LIBPCRE_1,"libpcre-1.dll"},
    std::pair<int, std::string>{DLL_LIBSODIUM_23,"libsodium-23.dll"},
    std::pair<int, std::string>{DLL_LIBWINPTHREAD_1,"libwinpthread-1.dll"},
    std::pair<int, std::string>{EXE_SS_LOCAL,"ss-local.exe"},
};

static DWORD _privoxyProcessId = 0;
static DWORD _ssProcessId = 0;

// settings
static int _localHttpPort = 1080;
static int _localSocksPort = 7039;

void writePrivoxyConfig() {
    std::vector<std::string> configuration{
        "listen-address 127.0.0.1:" + std::to_string(_localHttpPort),
        "toggle 0",
        "forward-socks5 / 127.0.0.1:" + std::to_string(_localSocksPort) + " .",
        "max-client-connections 2048",
        "activity-animation 0",
        "show-on-task-bar 0",
        "hide-console",
    };

    std::filesystem::path exePath = std::filesystem::current_path() / privoxyDir;
    std::ofstream configFile(exePath / privoxyConfig, std::ios::binary);

    for (std::string configLine : configuration) {
        configFile << configLine << "\r\n";
    }

    configFile.close();
}

void startPrivoxy() {
    if (_privoxyProcessId != 0) {
        // running
        return;
    }

    // start privoxy process. 
    STARTUPINFO startInfo{ sizeof(startInfo), 0 }; // set cb (first element) and others
    PROCESS_INFORMATION processInfo{ 0 };

    std::filesystem::path exePath = std::filesystem::current_path() / privoxyDir;
    std::wstring privoxy = exePath / privoxyExe;
    std::wstring command = exePath / privoxyConfig;
    std::wstring working = exePath;

    if (CreateProcess(privoxy.data(), command.data(),
        NULL, NULL, FALSE, CREATE_NO_WINDOW | CREATE_NEW_PROCESS_GROUP, NULL,
        working.data(), &startInfo, &processInfo)) {

        _privoxyProcessId = processInfo.dwProcessId;

        // Close process and thread handles. 
        CloseHandle(processInfo.hProcess);
        CloseHandle(processInfo.hThread);
    }
}

BOOL stopPrivoxy() {
    HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, _privoxyProcessId);
    if (hProcess != NULL) {
        TerminateProcess(hProcess, 0);

        DWORD waitResult = WaitForSingleObject(hProcess, 3000);
        if (waitResult == WAIT_OBJECT_0) {
            _privoxyProcessId = 0;
        } else {
            // TODO: (sorry) tell user terminate process manually
        }

        CloseHandle(hProcess);
        return waitResult == WAIT_OBJECT_0;
    }

    // not running
    return TRUE;
}

std::wstring WStringFromString(const std::string& string) {
    std::vector<wchar_t> buff(
        MultiByteToWideChar(CP_ACP, 0, string.c_str(), (int)(string.size() + 1), 0, 0)
    );

    MultiByteToWideChar(CP_ACP, 0, string.c_str(), (int)(string.size() + 1), &buff[0], (int)(buff.size()));

    return std::wstring(&buff[0]);
}

void startShadowsocks(int port, std::string& address, std::string& password, std::string& encrypt) {
    if (_ssProcessId != 0) {
        // running
        return;
    }

    // start privoxy process. 
    STARTUPINFO startInfo{ sizeof(startInfo), 0 }; // set cb (first element) and others
    PROCESS_INFORMATION processInfo{ 0 };

    std::filesystem::path exePath = std::filesystem::current_path() / ssDir;
    std::wstring ssLocal = exePath / ssLocalExe;
    std::wstring working = exePath;
    std::string command =
        " -s " + address + " -p " + std::to_string(port) +
        " -k " + password + " -m " + encrypt +
        " -l " + std::to_string(_localSocksPort) +
        " -u -t 3";

    // convert to wstring, the codecvt header are deprecated in C++17
    std::wstring wCommand = WStringFromString(command);

    if (CreateProcess(ssLocal.data(), wCommand.data(),
        NULL, NULL, FALSE, CREATE_NO_WINDOW | CREATE_NEW_PROCESS_GROUP, NULL,
        working.data(), &startInfo, &processInfo)) {

        _ssProcessId = processInfo.dwProcessId;

        // Close process and thread handles. 
        CloseHandle(processInfo.hProcess);
        CloseHandle(processInfo.hThread);
    }
}

BOOL stopShadowsocks() {
    HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, _ssProcessId);
    if (hProcess != NULL) {
        TerminateProcess(hProcess, 0);

        DWORD waitResult = WaitForSingleObject(hProcess, 3000);
        if (waitResult == WAIT_OBJECT_0) {
            _ssProcessId = 0;
        } else {
            // TODO: (sorry) tell user terminate process manually
        }

        CloseHandle(hProcess);
        return waitResult == WAIT_OBJECT_0;
    }

    // not running
    return TRUE;
}

void updateSettings(int localHttpPort, int localSocksPort) {
    if (localHttpPort > 0) {
        _localHttpPort = localHttpPort;
    }

    if (localSocksPort > 0) {
        _localSocksPort = localSocksPort;
    }
}

void cacheBinaries() {
    HMODULE hDll = GetModuleHandle(TEXT("xinlake_tunnel_plugin.dll"));
    if (hDll == NULL) {
        return;
    }

    // privoxy, shadowsocks
    std::map<std::string, std::vector<std::pair<int, std::string>>> dirs{
        {privoxyDir, privoxyFiles},
        {ssDir, ssFiles},
    };

    // load resource files
    std::filesystem::path appPath = std::filesystem::current_path();
    for (const auto& [dir, files] : dirs) {
        std::filesystem::create_directories(appPath / dir);

        for (std::pair<int, std::string> resItem : files) {
            int resId = resItem.first;
            std::filesystem::path filePath = appPath / dir / resItem.second;

            // skip this file if it's already exist
            if (std::filesystem::exists(filePath)) {
                continue;
            }

            HRSRC hResource = FindResource(hDll, MAKEINTRESOURCE(resId), RT_RCDATA);
            if (hResource == NULL) {
                continue;
            }

            HGLOBAL hMemory = LoadResource(hDll, hResource);
            if (hMemory == NULL) {
                continue;
            }

            LPVOID data = (char*)LockResource(hMemory);
            DWORD size = SizeofResource(hDll, hResource);

            // write data to file
            auto file = std::fstream(filePath, std::ios::out | std::ios::binary);
            file.write((char*)data, size);
            file.close();
        }
    }

    FreeLibrary(hDll);
    return;
}
