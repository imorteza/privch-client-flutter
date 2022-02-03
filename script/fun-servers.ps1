
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
        $address, $port, $password, $encrypt = $line.Trim().Split(' ');

        if ([string]::IsNullOrEmpty($address) -or [string]::IsNullOrEmpty($port) -or 
            [string]::IsNullOrEmpty($password) -or [string]::IsNullOrEmpty($encrypt)) {
            continue;
        }

        # trim and check server
        $address = $address.Trim();
        $port = $port.Trim();
        $password = $password.Trim();
        $encrypt = $encrypt.Trim();

        if ([string]::IsNullOrEmpty($address) -or [string]::IsNullOrEmpty($port) -or 
            [string]::IsNullOrEmpty($password) -or [string]::IsNullOrEmpty($encrypt)) {
            continue;
        }

        $ssList += $line;
    }

    return $ssList
}
