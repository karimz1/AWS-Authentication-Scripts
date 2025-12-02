<#
.SYNOPSIS
    Authenticates Docker with AWS ECR.
#>
param(
    [string]$RegionFallback = "us-east-1",   # Optional fallback region
    [string]$AccountId,                      # Optional 12-digit AWS account ID
    [switch]$SSO,                            # NEW: Force AWS SSO Login
    [Alias("help")]
    [switch]$ShowHelp                        
)


$appRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

try {
    Import-Module "$appRoot\modules\Logger.psm1" -ErrorAction Stop
    Import-Module "$appRoot\modules\AwsCliHelper.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Host "Error: Could not load required modules." -ForegroundColor Red
    exit 1
}

$LOG = "$appRoot\Logs\refreshEcrDockerToken.log"


function Auth-DockerToAwsEcr {
    param([string]$Region, [string]$OwnerId)

    Write-Log "Attempting to authenticate Docker with ECR ($Region)" $LOG

    $ecrLoginPassword = aws ecr get-login-password --region $Region
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Error: Failed to retrieve ECR login password. Session might be invalid." $LOG
        throw "ECR Password retrieval failed."
    }

    $registry = "$OwnerId.dkr.ecr.$Region.amazonaws.com"
    Write-Log "Target Registry: $registry" $LOG

    $ecrLoginPassword | docker login --username AWS --password-stdin $registry
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Error: Failed to log in to Docker." $LOG
        exit 1
    }

    Write-Log "Successfully logged in to Docker." $LOG
}


Write-Log "Starting refreshEcrDockerToken at $(Get-Date)" $LOG
$REGION = Get-Region -RegionFallback $RegionFallback

if ($SSO) {
    Write-Host "Initiating AWS SSO Login..." -ForegroundColor Cyan
    aws sso login
    if ($LASTEXITCODE -ne 0) {
        Write-Error "AWS SSO Login failed."
        exit 1
    }
}

if ([string]::IsNullOrWhiteSpace($AccountId)) {
    try {
        EnsureAwsSsoTokenIsValid -LogFile $LOG 
        $DOMAIN_OWNER_ID = Get-DomainOwnerId -LogFile $LOG
    }
    catch {
        Write-Error $_
        exit 1
    }
    Write-Log "AccountId retrieved via STS: $DOMAIN_OWNER_ID" $LOG
} else {
    $DOMAIN_OWNER_ID = $AccountId
    Write-Log "Using supplied AccountId: $DOMAIN_OWNER_ID" $LOG
}

Auth-DockerToAwsEcr -Region $REGION -OwnerId $DOMAIN_OWNER_ID

Write-Log "Done at $(Get-Date)" $LOG