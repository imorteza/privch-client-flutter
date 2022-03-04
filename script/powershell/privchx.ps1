$version = "0.4"
$ErrorActionPreference = "Stop"

# configurations
$exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$exePrivoxy = "D:\PrivChX\privoxy-x64\privoxy.exe"
$exeShadowsocksLocal = "D:\PrivChX\shadowsocks-libev-x64\ss-local.exe"

$txtPrivoxyConfig = "D:\PrivChX\privoxy-x64\config.txt"
$txtShadowsocksList = "D:\PrivChX\server-list.txt"

$localHttpPort = 17039;
$localSocksPort = 17029;

[System.Collections.ArrayList]$ssList = @()
[System.Collections.ArrayList]$ssInvalid = @()
$privoxyProcess = $null
$ssProcess = $null

Register-EngineEvent -SourceIdentifier PowerShell.Exiting -SupportEvent -Action {
    if (-not($null -eq $privoxyProcess)) {
        Stop-Process $privoxyProcess
        $privoxyProcess = $null
    }
    if (-not($null -eq $ssProcess)) {
        Stop-Process $ssProcess
        $ssProcess = $null
    }
}

# source and functions
Set-Location -Path "E:\PrivateChannel\SourceCode\script\powershell"
. .\fun-servers.ps1

function RandomValidServer {
    while ($true) {
        $shadowsocks = Get-Random -InputObject $Global:ssList
        $ssProcess = TestServer -ssLocal $exeShadowsocksLocal -shadowsocks $shadowsocks
        if ($null -eq $ssProcess) {
            $Global:ssInvalid += $shadowsocks
        } else {
            return $ssProcess
        }        
    }
}


# start 
"Private Channel X v$version"
"https://xinlake.dev"

# load and fix server list
Write-Host -ForegroundColor Magenta "`r`nLoad servers"
$ssList += LoadServers -path $txtShadowsocksList
if ($ssList.Count -le 1) {
    Write-Host "Server not found. Exit"
    Exit;
} else {
    Write-Host $ssList.Count "servers available"
    $ssList | Out-File -FilePath $txtShadowsocksList -Encoding "UTF8"
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
"`r`nR - [R]andom server" +
"`r`nB - open [B]rowser(Chrome) with --socks5-proxy=socks5://127.0.0.1:$localSocksPort" +
"`r`nC - open [C]md with http(s)_proxy=127.0.0.1:$localHttpPort" +
"`r`nL - open server [L]ist file" +
"`r`nS - remove invalid server and [S]ave to file" +
"`r`nQ - stop processes and [Q]uit`r`n"
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
                "set https_proxy=http://127.0.0.1:$localHttpPort&&", `
                "set http_proxy=http://127.0.0.1:$localHttpPort&&", `
                "set no_proxy=localhost,127.0.0.1,127.0.1.1,192.168.0.1,::1&&", `
                "cls"
        }
        "l" {
            & $txtShadowsocksList
        }
        "s" {
            if ($ssInvalid.Count -gt 0) {
                Write-Host "Remove" $ssInvalid.Count "invalid servers"
                foreach ($shadowsocks in $ssInvalid) {
                    $ssList.Remove($shadowsocks)
                }

                $ssInvalid.Clear()
                $ssList | Out-File -FilePath $txtShadowsocksList -Encoding "UTF8"
            }
            Write-Host $ssList.Count "servers available"
        }
        "q" {
            if (-not($null -eq $privoxyProcess)) {
                Stop-Process $privoxyProcess
                $privoxyProcess = $null
            }
            if (-not($null -eq $ssProcess)) {
                Stop-Process $ssProcess
                $ssProcess = $null
            }

            Write-Host "Exit"
            Exit
        }
        Default {}
    }
}
