param(
    [string]$RegionFallback = "us-east-1",  # Optional: Default fallback region
    [Alias("help")]                         # Allow `--help` as an alias for `-Help`
    [switch]$ShowHelp                       # Optional: Display help message
)

function Show-Help {
    $helpMessage = @"
    refreshEcrDockerToken.ps1 - A script to authenticate Docker with AWS ECR.

    PARAMETERS:
    -RegionFallback <string> : (Optional) Fallback region if AWS CLI default region is not configured.
                               Default: "us-east-1"

    -help                    : (Optional) Display this help message.

    USAGE:
    .\refreshEcrDockerToken.ps1 [-RegionFallback "region-name"] [-Help]

    EXAMPLES:
    1. Run with default settings:
       .\refreshEcrDockerToken.ps1

    2. Run with a specific fallback region and debug mode enabled:
       .\refreshEcrDockerToken.ps1 -RegionFallback "eu-west-1"

    3. Display help:
       .\refreshEcrDockerToken.ps1 -help
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

$LOG="$appRoot\Logs\refreshEcrDockerToken.log"
$REGION = Get-Region -RegionFallback $RegionFallback
$DOMAIN_NAME = Get-DomainName $REGION
$DOMAIN_OWNER_ID = Get-DomainOwnerId

# Function to authenticate Docker with Aws ECR
function AuthDockerToAwsEcr {
    Write-Log "Attempting to authenticate Docker with ECR" $LOG
    $ecrLoginPassword = aws ecr get-login-password --region $REGION
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to retrieve ECR login password" $LOG
        exit 1
    }

    $loginResult = $ecrLoginPassword | docker login --username AWS --password-stdin "$DOMAIN_OWNER_ID.dkr.ecr.$REGION.amazonaws.com"
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to log in to Docker" $LOG
        exit 1
    }

    Write-Log "Successfully logged in to Docker" $LOG
}


# Main script execution
Write-Log "Starting refreshEcrDockerToken script at $(Get-Date)" $LOG
AuthDockerToAwsEcr
Write-Log "Done at $(Get-Date)" $LOG
