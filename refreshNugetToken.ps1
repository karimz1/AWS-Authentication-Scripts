param(
    [string]$RegionFallback = "us-east-1",  # Optional: Default fallback region
    [bool]$DEBUG = $false,                  # Optional: Debug mode toggle
    [Alias("help")]                         # Allow `--help` as an alias for `-Help`
    [switch]$ShowHelp                       # Optional: Debug mode toggle
)


function Show-Help {
    $helpMessage = @"
    refreshNugetToken.ps1 - A script to refresh NuGet tokens using AWS CodeArtifact.

    PARAMETERS:
    -RegionFallback <string> : (Optional) Fallback region if AWS CLI default region is not configured.
                               Default: "us-east-1"

    -DEBUG <bool>            : (Optional) Enable debug mode for AWS CLI commands.
                               Default: false

    -help                    : (Optional) Display this help message.

    USAGE:
    .\refreshNugetToken.ps1 [-RegionFallback "region-name"] [-DEBUG `$true] [-Help]

    EXAMPLES:
    1. Run with default settings:
       .\refreshNugetToken.ps1

    2. Run with a specific fallback region and debug mode enabled:
       .\refreshNugetToken.ps1 -RegionFallback "eu-west-1" -DEBUG `$true

    3. Display help:
       .\refreshNugetToken.ps1 -help
"@
    Write-Output $helpMessage
}


if ($ShowHelp) {
    Show-Help
    exit 0
}

$appRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Import-Module "$appRoot\modules\Logger.psm1"
Import-Module "$appRoot\modules\AwsCliHelper.psm1"

$LOG="$appRoot\Logs\refreshNugetToken.log"
$DOMAIN_OWNER_ID = Get-DomainOwnerId

# Function to authenticate NuGet CLI with Aws CodeArtifact
function AuthNugetCli {
    $REGION = Get-Region -RegionFallback $RegionFallback
    $DOMAIN_NAME = Get-DomainName $REGION
    $REPOSITORIES = aws codeartifact list-repositories-in-domain --domain $DOMAIN_NAME --domain-owner $DOMAIN_OWNER_ID --region $REGION --query "repositories[].name" --output json | ConvertFrom-Json

    foreach ($REPOSITORY in $REPOSITORIES) {
        Write-Log "Logging into CodeArtifact for repository: $REPOSITORY" $LOG
        $loginCommand = "aws codeartifact login --tool dotnet --domain $DOMAIN_NAME --domain-owner $DOMAIN_OWNER_ID --repository $REPOSITORY --region $REGION"
		Write-Log "About to exec command: $loginCommand" $LOG
        if ($DEBUG) {
            $loginCommand += " --debug"
        }
        Invoke-Expression $loginCommand

        if ($LASTEXITCODE -eq 0) {
            Write-Log "Successfully logged in to $REPOSITORY" $LOG
        } else {
            Write-Log "Failed to log in to $REPOSITORY" $LOG
        }
		
		Write-Output "`n"
    }
    Write-Log "NuGet sources updated with new tokens for all repositories in the domain." $LOG
}

# Main script execution
Write-Log "Starting refreshNugetTokens script at $(Get-Date)" $LOG
Write-Output "`n"	
AuthNugetCli
Write-Log "Done at $(Get-Date)" $LOG