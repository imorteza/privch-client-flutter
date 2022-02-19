function LoadServers {
    param (
        [String]$path
    )
    if (-not($path)) {
        return ""
    }
    
    $ssTable = @{}
    foreach ($line in [System.IO.File]::ReadLines($path)) {
        # read and check server
        $address, $port, $password, $encrypt = -Split $line.Trim();

        if ([String]::IsNullOrEmpty($address) -or [String]::IsNullOrEmpty($port) -or 
            [String]::IsNullOrEmpty($password) -or [String]::IsNullOrEmpty($encrypt)) {
            continue;
        }

        $ssTable["$address-$port"] = "$address $port $password $encrypt";
    }

    return $ssTable.Values
}

function TestServer {
    param (
        [String]$ssLocal,
        [String]$shadowsocks
    )
    
    # start socks5
    $address, $port, $password, $encrypt = -Split $shadowsocks;
    Write-Host -ForegroundColor Magenta "`r`nCheck server: $address-$port ..."

    $ssProcess = Start-Process -FilePath $exeShadowsocksLocal -ArgumentList `
        '-s', $address, '-p', $port, `
        '-k', $password, '-m', $encrypt, `
        '-l', $localSocksPort, "-u", `
        "-t", 4 `
        -NoNewWindow -PassThru

    # make sure socks5 proxy is ready
    Start-Sleep -Milliseconds 100
    [System.Net.ServicePointManager]::MaxServicePointIdleTime = 7000

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
            Write-Host "Passed"
            return $ssProcess
        }
        Default {
            Stop-Process $ssProcess
            Write-Host "Failed"
            return $null
        }
    }
}
