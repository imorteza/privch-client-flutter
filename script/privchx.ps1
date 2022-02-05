$ErrorActionPreference = "Stop"

# source
. .\fun-servers.ps1

$exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$exePrivoxy = "D:\PrivChX\privoxy-x64\privoxy.exe"
$exeShadowsocksLocal = "D:\PrivChX\shadowsocks-libev-x64\ss-local.exe"

$txtPrivoxyConfig = "D:\PrivChX\privoxy-x64\config.txt"
$txtShadowsocksList = "D:\PrivChX\server-list.txt"

# port configuration 
$localHttpPort = 7070;
$localSocksPort = 33099;


# Begins here
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
[System.Collections.ArrayList]$ssInvalid = @();

# check socks5 proxy
foreach ($shadowsocks in $ssList) {
    $address, $port, $password, $encrypt = $shadowsocks.Split(' ');
    $address = $address.Trim();
    $port = $port.Trim();
    $password = $password.Trim();
    $encrypt = $encrypt.Trim();

    # start socks5
    Write-Host "`r`nCheck server: $address-$port ..."
    $ssProcess = Start-Process -FilePath $exeShadowsocksLocal -ArgumentList `
        '-s', $address, '-p', $port, `
        '-k', $password, '-m', $encrypt, `
        '-l', $localSocksPort `
        -NoNewWindow -PassThru

    # make sure socks5 proxy is ready
    Start-Sleep -Milliseconds 100

    try {
        $response = Invoke-WebRequest "https://www.google.com/" `
            -Proxy "http://127.0.0.1:$localHttpPort" `
            -ProxyUseDefaultCredentials
        $statusCode = $Response.StatusCode
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
    }

    if ($statusCode -eq 404) {
        Write-Host "Failed"
        Stop-Process $ssProcess
        $ssInvalid += $shadowsocks
    } else {
        Write-Host "Passed"
        break
    }
}

# remove invalid server and save to file
if ($ssInvalid.Count -gt 0) {
    Write-Host "Remove ${ssInvalid.Count} invalid servers"
    foreach ($shadowsocks in $ssInvalid) {
        $ssList.Remove($shadowsocks)
    }
    $ssList | Out-File -FilePath $txtShadowsocksList -Encoding "UTF8"
}

# done
$message = 
"`r`nB: open Browser(Chrome) with --socks5-proxy=socks5://127.0.0.1:$localSocksPort" +
"`r`nC: open Cmd with http(s)_proxy=127.0.0.1:$localHttpPort" +
"`r`nQ: stop processes and Quit" +
"`r`nSELECTION"
while ($true) {
    $option = Read-Host $message
    switch ($option.ToLower()) {
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
        "q" {
            Stop-Process $privoxyProcess
            Stop-Process $ssProcess
            Write-Host "Exit"
            Exit
        }
        Default {}
    }
}
