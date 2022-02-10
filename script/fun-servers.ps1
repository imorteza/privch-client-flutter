
function LoadServers {
    param (
        [string]$path
    )
    if (-not($path)) {
        return ""
    }
    
    [System.Collections.ArrayList]$ssList = @();
    foreach ($line in [System.IO.File]::ReadLines($path)) {
        # read and check server
        $address, $port, $password, $encrypt = -Split $line.Trim();

        if ([string]::IsNullOrEmpty($address) -or [string]::IsNullOrEmpty($port) -or 
            [string]::IsNullOrEmpty($password) -or [string]::IsNullOrEmpty($encrypt)) {
            continue;
        }

        $ssList += $line;
    }

    return $ssList
}

function TestServer {
    param (
        $ssLocal,
        $shadowsocks
    )
    
    # start socks5
    $address, $port, $password, $encrypt = -Split $shadowsocks;
    Write-Host "`r`nCheck server: $address-$port ..."

    $ssProcess = Start-Process -FilePath $exeShadowsocksLocal -ArgumentList `
        '-s', $address, '-p', $port, `
        '-k', $password, '-m', $encrypt, `
        '-l', $localSocksPort, "-u", `
        "-t", 5 `
        -NoNewWindow -PassThru

    # make sure socks5 proxy is ready
    Start-Sleep -Milliseconds 100
    [System.Net.ServicePointManager]::MaxServicePointIdleTime = 10000

    try {
        $response = Invoke-WebRequest "https://www.google.com/" `
            -Proxy "http://127.0.0.1:$localHttpPort" `
            -ProxyUseDefaultCredentials
        -TimeoutSec 3
        $statusCode = $Response.StatusCode
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
    }

    switch ($statusCode) {
        { $_ -in 429, 200 } {
            return $ssProcess
        }
        Default {
            Stop-Process $ssProcess
            return $null
        }
    }
}
