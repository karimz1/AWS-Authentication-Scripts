<#
.SYNOPSIS
    Refreshes NuGet tokens using AWS CodeArtifact.
#>
param(
    [string]$RegionFallback = "us-east-1",  # Optional: Default fallback region
    [bool]$DEBUG = $false,                  # Optional: Debug mode toggle
    [switch]$SSO,                           # NEW: Force AWS SSO Login before running
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

$LOG = "$appRoot\Logs\refreshNugetToken.log"

function AuthNugetCli {
    param(
        [string]$Region,
        [string]$DomainName,
        [string]$DomainOwnerId
    )
    
    Write-Log "Fetching repositories from CodeArtifact domain '$DomainName'..." $LOG
    
    try {
        $REPOSITORIES = aws codeartifact list-repositories-in-domain --domain $DomainName --domain-owner $DomainOwnerId --region $Region --query "repositories[].name" --output json | ConvertFrom-Json
    }
    catch {
        Write-Log "Error: Failed to list repositories. Check your region and permissions." $LOG
        throw $_
    }

    foreach ($REPOSITORY in $REPOSITORIES) {
        Write-Log "Logging into CodeArtifact for repository: $REPOSITORY" $LOG
        
        $loginCommand = "aws codeartifact login --tool dotnet --domain $DomainName --domain-owner $DomainOwnerId --repository $REPOSITORY --region $Region"
        
        if ($DEBUG) {
            Write-Log "[DEBUG] Command: $loginCommand" $LOG
        }
        
        Invoke-Expression $loginCommand

        if ($LASTEXITCODE -eq 0) {
            Write-Log "Successfully logged in to $REPOSITORY" $LOG
            Write-Host "Success: $REPOSITORY" -ForegroundColor Green
        } else {
            Write-Log "Failed to log in to $REPOSITORY (Exit Code: $LASTEXITCODE)" $LOG
            Write-Host "Failed: $REPOSITORY" -ForegroundColor Red
        }
    }
    Write-Log "NuGet sources updated with new tokens for all repositories in the domain." $LOG
}


Write-Log "Starting refreshNugetTokens script at $(Get-Date)" $LOG
Write-Output "`n"

if ($SSO) {
    Write-Host "Initiating AWS SSO Login..." -ForegroundColor Cyan
    aws sso login
    if ($LASTEXITCODE -ne 0) {
        Write-Error "AWS SSO Login failed. Exiting."
        exit 1
    }
    Write-Host "AWS SSO Login Successful.`n" -ForegroundColor Green
}

try {
    EnsureAwsSsoTokenIsValid -LogFile $LOG 
}
catch {
    Write-Error "Authentication check failed. Rerunning with -SSO might fix this."
    throw $_
}


$REGION = Get-Region -RegionFallback $RegionFallback
$DOMAIN_OWNER_ID = Get-DomainOwnerId -LogFile $LOG
$DOMAIN_NAME = Get-DomainName -Region $REGION -LogFile $LOG

AuthNugetCli -Region $REGION -DomainName $DOMAIN_NAME -DomainOwnerId $DOMAIN_OWNER_ID

Write-Log "Done at $(Get-Date)" $LOG