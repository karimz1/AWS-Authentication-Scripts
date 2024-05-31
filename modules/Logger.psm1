function Write-Log {
    param(
        [string]$Message,
        [string]$LogFileName
    )

    $logDirectory = Split-Path -Parent -Path $LogFileName

    if (-not (Test-Path $logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory | Out-Null
    }

    $maxFileSize = 10MB
    Add-Content -Path $LogFileName -Value ("{0:yyyy-MM-dd HH:mm:ss} - {1}" -f (Get-Date), $Message)

    while ((Get-Item $LogFileName).Length -gt $maxFileSize) {
        $content = Get-Content $LogFileName
        $skipLines = [math]::Round($content.Count * 0.1)
        $content = $content | Select-Object -Skip $skipLines
        Set-Content -Path $LogFileName -Value $content
    }
}