# v0.9.2
# - update to the sslocal rust implementation
# v0.9.1
# - Start the privoxy process when needed
# - Manually save the server list
# v0.9.0
# - Automatically delete nodes that have failed more than 10 consecutive times

$version = "0.9.2"
$ErrorActionPreference = "Stop"

# configurations
$Global:exeCurl = "D:\cURL\win64-mingw\bin\curl.exe"
$exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$Global:exeShadowsocksLocal = "D:\PrivChX\shadowsocks-rust-x64\sslocal.exe"
$txtShadowsocksList = "D:\PrivChX\server-list.txt"

$localHttpPort = 17039;
$localSocksPort = 17029;

[System.Collections.ArrayList]$ssList = @()
$Global:shadowsocks = $null
$ssProcessH = $null
$ssProcess = $null

# source and functions
Set-Location -Path "E:\PrivateChannel\SourceCode\script\powershell"
. .\shadowsocks.ps1

function NextValidServer {
    foreach ($Global:shadowsocks in $ssList) {
        # $shadowsocks = Get-Random -InputObject $ssList
        if ($Global:shadowsocks.failTimes -gt 10) {
            continue; 
        }

        $ssProcess = TestServer -shadowsocks $Global:shadowsocks
        if ($null -eq $ssProcess) {
            $Global:shadowsocks.failTimes++
        } else {
            $Global:shadowsocks.failTimes = 0
            
            SaveServer -path $txtShadowsocksList -ssList $ssList
            return $ssProcess
        }    
    }
    
    $Global:shadowsocks = $null
    SaveServer -path $txtShadowsocksList -ssList $ssList
    Write-Host -ForegroundColor Red "`r`nNo valid server found"
}

function Shutdown {
    if (-not($null -eq $ssProcessH)) {
        Stop-Process $ssProcessH
        $ssProcessH = $null
    }
    if (-not($null -eq $ssProcess)) {
        Stop-Process $ssProcess
        $ssProcess = $null
    }
}

Register-EngineEvent -SourceIdentifier PowerShell.Exiting -SupportEvent -Action {
    Shutdown
}


# start 
"Private Channel X v$version"
"https://xinlake.dev"

# load and fix server list
Write-Host -ForegroundColor Magenta "`r`nLoad servers"
LoadServer -path $txtShadowsocksList -ssList $ssList
if ($ssList.Count -lt 1) {
    Write-Host "Server not found. Exit"
    Exit;
} else {
    Write-Host $($ssList.Count) "servers available"
    SaveServer -path $txtShadowsocksList -ssList $ssList
}

# check socks5 proxy
$ssProcess = NextValidServer

# done
[Console]::TreatControlCAsInput = $True

$message = 
"`r`nSELECT" +
"`r`nN  - connect to Next server" +
"`r`n----" + 
"`r`nB  - open Browser(Chrome) with --socks5-proxy=socks5://127.0.0.1:$localSocksPort" +
"`r`nC  - open Cmd with http(s)_proxy=socks5h://127.0.0.1:$localSocksPort" +
"`r`nCH - open Cmd with http(s)_proxy=127.0.0.1:$localHttpPort" +
"`r`n----" + 
"`r`nO  - Open server list file" +
"`r`nQ  - stop processes save servers then Quit`r`n"
while ($true) {
    $option = Read-Host $message
    switch ($option.ToLower()) {
        "n" {
            if (-not($null -eq $ssProcess)) {
                Write-Host "`r`nStop socks server"
                Stop-Process $ssProcess
            }

            $ssProcess = NextValidServer
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
            if ($null -eq $Global:shadowsocks) {
                break
            }

            # start sslocal with http protocol parameter
            if ($null -eq $ssProcessH) {
                Write-Host -ForegroundColor Magenta "`r`nStart sslocal http ..."
                $ssProcessH = Start-Process -FilePath $Global:exeShadowsocksLocal `
                    -NoNewWindow -PassThru -ArgumentList `
                    "-s $($Global:shadowsocks.address):$($Global:shadowsocks.port)", `
                    "-k $($Global:shadowsocks.password) -m $($Global:shadowsocks.encrypt)", `
                    "-b 127.0.0.1:$Global:localHttpPort --protocol http -U --timeout 5"

                # make sure process is ready
                Start-Sleep -Milliseconds 100
            }

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
            SaveServer -path $txtShadowsocksList -ssList $ssList
            Shutdown

            Exit
        }
        Default {}
    }
}
