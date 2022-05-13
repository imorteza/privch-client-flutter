# v0.9.0
# - Automatically delete nodes that have failed more than 10 consecutive times

$version = "0.9.0"
$ErrorActionPreference = "Stop"

# configurations
$Global:exeCurl = "D:\cURL\win64-mingw\bin\curl.exe"
$exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$exePrivoxy = "D:\PrivChX\privoxy-x64\privoxy.exe"
$Global:exeShadowsocksLocal = "D:\PrivChX\shadowsocks-libev-x64\ss-local.exe"

$txtPrivoxyConfig = "D:\PrivChX\privoxy-x64\config.txt"
$txtShadowsocksList = "D:\PrivChX\server-list.txt"

$localHttpPort = 17039;
$localSocksPort = 17029;

[System.Collections.ArrayList]$ssList = @()
$privoxyProcess = $null
$ssProcess = $null

# source and functions
Set-Location -Path "E:\PrivateChannel\SourceCode\script\powershell"
. .\shadowsocks.ps1

function RandomValidServer {
    while ($true) {
        $shadowsocks = Get-Random -InputObject $ssList
        $ssProcess = TestServer -shadowsocks $shadowsocks
        if ($null -eq $ssProcess) {
            # silent
            $shadowsocks.failTimes++
            if ($shadowsocks.failTimes -ge 10) {
                $ssList.Remove($shadowsocks)
                Write-Host $ssList.Count "servers remain"

                if ($ssList.Count -le 1) {
                    Shutdown
                    
                    Write-Host "No server available. Exit"
                    Exit;
                }
            }
        } else {
            $shadowsocks.failTimes = 0
            return $ssProcess
        }        
    }
}

function Shutdown {
    if (-not($null -eq $privoxyProcess)) {
        Stop-Process $privoxyProcess
        $privoxyProcess = $null
    }
    if (-not($null -eq $ssProcess)) {
        Stop-Process $ssProcess
        $ssProcess = $null
    }
}

Register-EngineEvent -SourceIdentifier PowerShell.Exiting -SupportEvent -Action {
    Shutdown
    SaveServer -path $txtShadowsocksList -ssList $ssList
}


# start 
"Private Channel X v$version"
"https://xinlake.dev"

# load and fix server list
Write-Host -ForegroundColor Magenta "`r`nLoad servers"
LoadServer -path $txtShadowsocksList -ssList $ssList
if ($ssList.Count -le 1) {
    Write-Host "Server not found. Exit"
    Exit;
} else {
    Write-Host $($ssList.Count) "servers available"
    SaveServer -path $txtShadowsocksList -ssList $ssList
}

# start privoxy daemon
Write-Host -ForegroundColor Magenta "`r`nStart privoxy ..."
$privoxyConfig = "listen-address 127.0.0.1:$localHttpPort" +
"`r`ntoggle 0" +
"`r`nforward-socks5 / 127.0.0.1:$localSocksPort ." +
"`r`nmax-client-connections 2048" +
"`r`nactivity-animation 0" +
"`r`nshow-on-task-bar 0" +
"`r`nhide-console"
$privoxyConfig | Out-File -FilePath $txtPrivoxyConfig -Encoding "ASCII"
$privoxyProcess = Start-Process -FilePath $exePrivoxy -ArgumentList $txtPrivoxyConfig `
    -NoNewWindow -PassThru

# make sure privoxy is ready
Start-Sleep -Milliseconds 100

# check socks5 proxy
$ssProcess = RandomValidServer

# done
[Console]::TreatControlCAsInput = $True

$message = 
"`r`nSELECT" +
"`r`nR  - Reconnect to a random server and Remove invalid server" +
"`r`n----" + 
"`r`nB  - open Browser(Chrome) with --socks5-proxy=socks5://127.0.0.1:$localSocksPort" +
"`r`nC  - open Cmd with http(s)_proxy=socks5h://127.0.0.1:$localSocksPort" +
"`r`nCH - open Cmd with http(s)_proxy=127.0.0.1:$localHttpPort" +
"`r`n----" + 
"`r`nO  - Open server list file" +
"`r`nQ  - stop processes and Quit`r`n"
while ($true) {
    $option = Read-Host $message
    switch ($option.ToLower()) {
        "r" {
            if (-not($null -eq $ssProcess)) {
                Write-Host "`r`nStop socks server"
                Stop-Process $ssProcess
            }
            $ssProcess = RandomValidServer
        }

        "b" {
            & $exeChrome --proxy-server="socks5://127.0.0.1:$localSocksPort" 
        }
        "c" {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/k", `
                "set https_proxy=socks5h://127.0.0.1:$localSocksPort&&", `
                "set http_proxy=socks5h://127.0.0.1:$localSocksPort&&", `
                "set no_proxy=localhost,127.0.0.1,127.0.1.1,192.168.0.1,::1&&", `
                "cls"
        }
        "ch" {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/k", `
                "set https_proxy=http://127.0.0.1:$localHttpPort&&", `
                "set http_proxy=http://127.0.0.1:$localHttpPort&&", `
                "set no_proxy=localhost,127.0.0.1,127.0.1.1,192.168.0.1,::1&&", `
                "cls"
        }

        "o" {
            & $txtShadowsocksList
        }
        "q" {
            Shutdown
            SaveServer -path $txtShadowsocksList -ssList $ssList

            Write-Host "Exit"
            Exit
        }
        Default {}
    }
}
