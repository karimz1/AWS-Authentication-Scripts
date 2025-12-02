# Path: ./modules/AwsCliHelper.psm1

function Get-Region {
    param(
        [string]$RegionFallback = "us-east-1"
    )
    $region = aws configure get region --output text
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($region)) {
        return $RegionFallback
    }
    return $region
}

function Get-DomainOwnerId {
    param([string]$LogFile)

    $domainOwnerId = aws sts get-caller-identity --query "Account" --output text
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($domainOwnerId)) {
        $errMsg = "Failed to retrieve domain owner ID (Account ID)."
        if ($LogFile) { Write-Log $errMsg $LogFile } else { Write-Error $errMsg }
        exit 1
    }
    return $domainOwnerId
}

function Get-DomainName {
    param(
        [string]$Region,
        [string]$LogFile
    )
    
    $domainName = aws codeartifact list-domains --region $Region --query "domains[0].name" --output text
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($domainName)) {
        $errMsg = "Failed to retrieve CodeArtifact domain name."
        if ($LogFile) { Write-Log $errMsg $LogFile } else { Write-Error $errMsg }
        exit 1
    }
    return $domainName
}

function EnsureAwsSsoTokenIsValid {
    param([string]$LogFile)

    $stsOutput = & aws sts get-caller-identity 2>&1
    if ($LASTEXITCODE -eq 0) { return } # Token is valid

    $currentProfile = if ($env:AWS_PROFILE) { $env:AWS_PROFILE } else { "default" }
    
    # Check authentication method using aws configure list
    $authConfig = & aws configure list --profile $currentProfile 2>$null
    # Extract auth type safely
    $authType = "unknown"
    if ($authConfig -match "access_key.*Type\s+(\w+)") {
         $authType = $matches[1].ToLower()
    }
    
    $err = "$stsOutput"
    
    switch ($authType) {
        "sso" {
            # Heuristic check for expired token messages
            if ($err -match 'SSO.*expired|Token has expired|refresh failed|The SSO session associated with this profile has expired') {
                $msg = "AWS SSO appears expired. Attempting auto-login for profile '$currentProfile'..."
                if ($LogFile) { Write-Log $msg $LogFile } else { Write-Host $msg -ForegroundColor Yellow }

                & aws sso login
                if ($LASTEXITCODE -ne 0) {
                    throw "AWS SSO login failed. Please run 'aws sso login' manually."
                }
                
                # Re-check STS after login
                & aws sts get-caller-identity *> $null
                if ($LASTEXITCODE -ne 0) {
                    throw "AWS credentials still invalid after SSO login."
                }
            } else {
                throw "AWS SSO authentication failed: $err"
            }
        }
        "iam" {
            throw "AWS IAM access key authentication failed for profile '$currentProfile'. Please check your credentials."
        }
        default {
            throw "No valid authentication found for profile '$currentProfile'. AWS Error: $err"
        }
    }
}

Export-ModuleMember -Function Get-Region, Get-DomainOwnerId, Get-DomainName, EnsureAwsSsoTokenIsValid