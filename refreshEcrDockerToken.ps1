param(
    [string]$RegionFallback = "us-east-1",   # Optional fallback region
    [string]$AccountId,                      # Optional 12-digit AWS account ID
    [Alias("help")]
    [switch]$ShowHelp                        # Show this help & exit
)

function Show-Help {
    $helpMessage = @"
refreshEcrDockerToken.ps1 - Authenticate Docker with AWS ECR.

PARAMETERS
  -AccountId <string>     Optional. 12-digit AWS account ID.  
                          When provided, the script does NOT call
                          sts:GetCallerIdentity, so the IAM policy
                          can omit that action entirely.

  -RegionFallback <string> Optional fallback region if AWS CLI has
                          no default.  Default: "us-east-1"

  -help                   Show this help.

USAGE
  .\refreshEcrDockerToken.ps1                 # auto-detect account ID
  .\refreshEcrDockerToken.ps1 -AccountId 123456789012
  .\refreshEcrDockerToken.ps1 -RegionFallback eu-west-1
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

$LOG    = "$appRoot\Logs\refreshEcrDockerToken.log"
$REGION = Get-Region -RegionFallback $RegionFallback

# ------------------------------------------------------------------
# Determine the account ID (registry owner)
# ------------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($AccountId)) {
    $DOMAIN_OWNER_ID = Get-DomainOwnerId
    Write-Log "AccountId not supplied - retrieved via STS: $DOMAIN_OWNER_ID" $LOG
} else {
    $DOMAIN_OWNER_ID = $AccountId
    Write-Log "Using supplied AccountId: $DOMAIN_OWNER_ID" $LOG
}

# ------------------------------------------------------------------
# Authenticate Docker with AWS ECR
# ------------------------------------------------------------------
function Auth-DockerToAwsEcr {
    Write-Log "Attempting to authenticate Docker with ECR" $LOG

    $ecrLoginPassword = aws ecr get-login-password --region $REGION
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to retrieve ECR login password" $LOG
        exit 1
    }

    $registry = "$DOMAIN_OWNER_ID.dkr.ecr.$REGION.amazonaws.com"

    $ecrLoginPassword | docker login --username AWS --password-stdin $registry
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to log in to Docker" $LOG
        exit 1
    }

    Write-Log "Successfully logged in to Docker for $registry" $LOG
}

# ------------------------------------------------------------------
# Main
# ------------------------------------------------------------------
Write-Log "Starting refreshEcrDockerToken at $(Get-Date)" $LOG
Auth-DockerToAwsEcr
Write-Log "Done at $(Get-Date)" $LOG