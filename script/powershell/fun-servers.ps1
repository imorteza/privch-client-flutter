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

    $ssProcess = Start-Process -FilePath $ssLocal -ArgumentList `
        '-s', $address, '-p', $port, `
        '-k', $password, '-m', $encrypt, `
        '-l', $localSocksPort, "-u", `
        "-t", 4 `
        -NoNewWindow -PassThru

    # make sure socks5 proxy is ready
    Start-Sleep -Milliseconds 100

    $statusCode = & curl.exe -s -o NUL `
        --connect-timeout 5 `
        --max-time 7 `
        -x socks5h://localhost:17029 `
        --head -w "%{http_code}" `
        https://google.com

    switch ($statusCode) {
        { $_ -in 204, 200, 429 } {
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
