$appRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Import-Module "$appRoot\modules\Logger.psm1"
Import-Module "$appRoot\modules\AwsCliHelper.psm1"

# start Configuration
$REGION = "us-east-1"
$DEBUG = $false
# end Configuration

$LOG="$appRoot\Logs\refreshNugetToken.log"
$DOMAIN_OWNER_ID = Get-DomainOwnerId

# Function to authenticate NuGet CLI with Aws CodeArtifact
function AuthNugetCli {
    $DOMAIN_NAME = Get-DomainName $REGION
    $REPOSITORIES = aws codeartifact list-repositories-in-domain --domain $DOMAIN_NAME --domain-owner $DOMAIN_OWNER_ID --region $REGION --query "repositories[].name" --output text
    $REPOSITORY_LIST = $REPOSITORIES -split "\s+"

    foreach ($REPOSITORY in $REPOSITORY_LIST) {
        Write-Log "Logging into CodeArtifact for repository: $REPOSITORY" $LOG
        $loginCommand = "aws codeartifact login --tool dotnet --domain $DOMAIN_NAME --domain-owner $DOMAIN_OWNER_ID --repository $REPOSITORY --region $REGION"
        if ($DEBUG) {
            $loginCommand += " --debug"
        }
        Invoke-Expression $loginCommand

        if ($LASTEXITCODE -eq 0) {
            Write-Log "Successfully logged in to $REPOSITORY" $LOG
        } else {
            Write-Log "Failed to log in to $REPOSITORY" $LOG
        }
    }
    Write-Log "NuGet sources updated with new tokens for all repositories in the domain." $LOG
}

# Main script execution
Write-Log "Starting refreshNugetTokens script at $(Get-Date)" $LOG
AuthNugetCli
Write-Log "Done at $(Get-Date)" $LOG
