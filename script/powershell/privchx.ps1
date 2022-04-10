$version = "0.6"
$ErrorActionPreference = "Stop"

# configurations
$exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$exeShadowsocksLocal = "D:\PrivChX\shadowsocks-libev-x64\ss-local.exe"
$txtShadowsocksList = "D:\PrivChX\server-list.txt"

$localSocksPort = 17029;

[System.Collections.ArrayList]$ssList = @()
[System.Collections.ArrayList]$ssInvalid = @()
$ssProcess = $null

Register-EngineEvent -SourceIdentifier PowerShell.Exiting -SupportEvent -Action {
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

# check socks5 proxy
$ssProcess = RandomValidServer

# done
[Console]::TreatControlCAsInput = $True

$message = 
"`r`nSELECT" +
"`r`nR - [R]econnect to a random server" +
"`r`nB - open [B]rowser(Chrome) with --socks5-proxy=socks5://127.0.0.1:$localSocksPort" +
"`r`nC - open [C]md with http(s)_proxy=socks5h://127.0.0.1:$localSocksPort" +
"`r`nL - [O]pen server list file" +
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
                "set https_proxy=socks5h://127.0.0.1:$localSocksPort&&", `
                "set http_proxy=socks5h://127.0.0.1:$localSocksPort&&", `
                "set no_proxy=localhost,127.0.0.1,127.0.1.1,192.168.0.1,::1&&", `
                "cls"
        }
        "o" {
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
