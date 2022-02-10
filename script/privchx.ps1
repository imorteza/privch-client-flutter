$ErrorActionPreference = "Stop"

$exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$exePrivoxy = "D:\PrivChX\privoxy-x64\privoxy.exe"
$exeShadowsocksLocal = "D:\PrivChX\shadowsocks-libev-x64\ss-local.exe"

$txtPrivoxyConfig = "D:\PrivChX\privoxy-x64\config.txt"
$txtShadowsocksList = "D:\PrivChX\server-list.txt"

# source and configuration
Set-Location -Path "E:\PrivateChannel\SourceCode\script"
. .\fun-servers.ps1

$localHttpPort = 7070;
$localSocksPort = 33099;

# load and fix server list
Write-Host "Load servers"
[System.Collections.ArrayList]$ssList = LoadServers -path $txtShadowsocksList
if ($ssList.Count -le 1) {
    Write-Host "Server not found. Exit"
    Exit;
} else {
    Write-Host $ssList.Count "servers available"
    $ssList | Out-File -FilePath $txtShadowsocksList -Encoding "UTF8"
}

# start privoxy daemon
Write-Host "`r`nStart privoxy ..."
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
[System.Collections.ArrayList]$ssInvalid = @();

$shadowsocks = Get-Random -InputObject $ssList
$ssProcess = TestServer -ssLocal $exeShadowsocksLocal -shadowsocks $shadowsocks
if ($null -eq $ssProcess) {
    Write-Host "Failed"
    $ssInvalid += $shadowsocks
} else {
    Write-Host "Passed"
}

# done
$message = 
"`r`nR: Random server" +
"`r`nB: open Browser(Chrome) with --socks5-proxy=socks5://127.0.0.1:$localSocksPort" +
"`r`nC: open Cmd with http(s)_proxy=127.0.0.1:$localHttpPort" +
"`r`nS: remove invalid server and Save to file" +
"`r`nQ: stop processes and Quit" +
"`r`nSELECTION"
while ($true) {
    $option = Read-Host $message
    switch ($option.ToLower()) {
        "r" {
            if (-not($null -eq $ssProcess)) {
                Write-Host "`r`nStop socks server"
                Stop-Process $ssProcess
            }

            $shadowsocks = Get-Random -InputObject $ssList
            $ssProcess = TestServer -ssLocal $exeShadowsocksLocal -shadowsocks $shadowsocks
            if ($null -eq $ssProcess) {
                Write-Host "Failed"
                $ssInvalid += $shadowsocks
            } else {
                Write-Host "Passed"
            }
        }
        "b" {
            & $exeChrome --proxy-server="socks5://127.0.0.1:$localSocksPort" 
        }
        "c" {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/k", `
                "set https_proxy=http://127.0.0.1:$localHttpPort&&", `
                "set http_proxy=http://127.0.0.1:$localHttpPort&&", `
                "set no_proxy=localhost,127.0.0.1,127.0.1.1,192.168.0.1,::1&&", `
                "cls"
        }
        "d" {
            if ($ssInvalid.Count -gt 0) {
                Write-Host "Remove ${ssInvalid.Count} invalid servers"
                foreach ($shadowsocks in $ssInvalid) {
                    $ssList.Remove($shadowsocks)
                }
                $ssList | Out-File -FilePath $txtShadowsocksList -Encoding "UTF8"
            }
            Write-Host $ssList.Count "servers available"
        }
        "q" {
            Stop-Process $privoxyProcess
            Stop-Process $ssProcess
            Write-Host "Exit"
            Exit
        }
        Default {}
    }
}
