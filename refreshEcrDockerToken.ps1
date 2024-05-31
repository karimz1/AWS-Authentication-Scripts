$appRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Import-Module "$appRoot\modules\Logger.psm1"
Import-Module "$appRoot\modules\AwsCliHelper.psm1"


# start Configuration
$REGION = "us-east-1"
# end Configuration

$LOG="$appRoot\Logs\refreshEcrDockerToken.log"
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
