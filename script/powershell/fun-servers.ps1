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
        [String]$shadowsocks
    )
    
    # start socks5
    $address, $port, $password, $encrypt = -Split $shadowsocks;
    Write-Host -ForegroundColor Magenta "`r`nCheck server: $address-$port ..."

    $ssProcess = Start-Process -FilePath $Global:exeShadowsocksLocal `
        -NoNewWindow -PassThru -ArgumentList `
        "-s $address -p $port -k $password -m $encrypt", `
        "-l $Global:localSocksPort -u -t 5"

    # make sure socks5 proxy is ready
    Start-Sleep -Milliseconds 100

    $statusCode = & $Global:exeCurl -s -o NUL `
        --connect-timeout 6 `
        -x socks5h://localhost:17029 `
        --location --insecure --head -w "%{http_code}" `
        "https://xinlake.dev"

    switch ($statusCode) {
        { $_ -in 200, 204, 301, 429 } {
            Write-Host  "Passed:" $statusCode
            return $ssProcess
        }
        Default {
            Stop-Process $ssProcess
            Write-Host "Failed:" $statusCode
            return $null
        }
    }
}
