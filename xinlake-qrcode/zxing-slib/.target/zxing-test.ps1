$ErrorActionPreference = "Stop"

Write-Host -ForegroundColor Green "`r`nencode -size 1000x1000 QRCode https://xinlake.dev xinlake.png"
& x64.Debug\encode.exe -size 1000x1000 QRCode https://xinlake.dev xinlake.png

Write-Host -ForegroundColor Green "`r`ndecode xinlake.png"
& x64.Debug\decode.exe xinlake.png

Write-Host -ForegroundColor Green "`r`nHit ENTER to close ..."
Read-Host
