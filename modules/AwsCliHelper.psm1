function Get-DomainName {
    param(
        [string]$Region
    )
    
    $domainName = aws codeartifact list-domains --region $Region --query "domains[0].name" --output text
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($domainName)) {
        Write-Log "Failed to retrieve domain name" $LogFileName
        exit 1
    }
    return $domainName
}

function Get-Region {
    param(
        [string]$RegionFallback
    )
    $region = aws configure get region --output text
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($region)) {
        $region = $RegionFallback
    }
    return $region
}

function Get-DomainOwnerId {
    $domainOwnerId = aws sts get-caller-identity --query "Account" --output text
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($domainOwnerId)) {
        Write-Log "Failed to retrieve domain owner ID" $LogFileName
        exit 1
    }
    return $domainOwnerId
}