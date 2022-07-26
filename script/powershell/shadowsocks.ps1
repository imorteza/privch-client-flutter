class Shadowsocks {
    [string]$address
    [string]$port
    [string]$password
    [string]$encrypt
    [int]$failTimes

    # Equals() is required for remove from list.
    [bool] Equals([Object] $other) {
        return ($this.address -eq $other.address) `
            -and ($this.port -eq $other.port) `
            -and ($this.password -eq $other.password) `
            -and ($this.encrypt -eq $other.encrypt);   
    }

    [string] ToString() {
        return "$($this.address) $($this.port) $($this.password) $($this.encrypt) $($this.failTimes)";
    }
}

function LoadServer {
    param (
        [String]$path,
        [System.Collections.ArrayList]$ssList
    )
    if ([String]::IsNullOrEmpty($path)) {
        Throw "Invalid Parameter"
    }
    if ($null -eq $ssList) {
        Throw "Invalid Parameter"
    }
    
    foreach ($line in [System.IO.File]::ReadLines($path)) {
        # read and check server
        $address, $port, $password, $encrypt, $failTimes = -Split $line.Trim();

        if ([String]::IsNullOrEmpty($address) -or [String]::IsNullOrEmpty($port) -or 
            [String]::IsNullOrEmpty($password) -or [String]::IsNullOrEmpty($encrypt)) {
            continue;
        }

        if ([String]::IsNullOrEmpty($failTimes)) {
            $failTimes = "0";
        }

        $shadowsocks = [Shadowsocks]::new()
        $shadowsocks.address = $address
        $shadowsocks.port = $port
        $shadowsocks.password = $password
        $shadowsocks.encrypt = $encrypt
        $shadowsocks.failTimes = [convert]::ToInt32($failTimes)
        [void]$ssList.Add($shadowsocks)
    }
}

function SaveServer {
    param (
        [String]$path,
        [System.Collections.ArrayList]$ssList
    )
    if ([String]::IsNullOrEmpty($path)) {
        Throw "Invalid Parameter"
    }
    if ($null -eq $ssList) {
        Throw "Invalid Parameter"
    }
    
    [System.Collections.ArrayList]$fileContent = @()
    ForEach ($shadowsocks in $ssList) {
        [void]$fileContent.Add($shadowsocks.ToString())
    }

    $fileContent | Out-File -FilePath $txtShadowsocksList -Encoding "UTF8"
}

function TestServer {
    param (
        [Shadowsocks]$shadowsocks
    )
    if ($null -eq $ssList) {
        Throw "Invalid Parameter"
    }
        
    # start socks5
    Write-Host -ForegroundColor Magenta `
        "`r`nCheck server: $($shadowsocks.address)-$($shadowsocks.port) ..."

    $ssProcess = Start-Process -FilePath $Global:exeShadowsocksLocal `
        -NoNewWindow -PassThru -ArgumentList `
        "-s $($shadowsocks.address):$($shadowsocks.port)", `
        "-k $($shadowsocks.password) -m $($shadowsocks.encrypt)", `
        "-b 127.0.0.1:$Global:localSocksPort -U --timeout 5"

    # make sure socks5 proxy is ready
    Start-Sleep -Milliseconds 100

    $statusCode = & $Global:exeCurl -s -o NUL `
        --connect-timeout 6 `
        -x socks5h://127.0.0.1:$($Global:localSocksPort) `
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
