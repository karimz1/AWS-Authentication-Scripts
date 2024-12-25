# AWS Authentication Scripts

## Overview

Welcome to the AWS Authentication Scripts repository! This project contains PowerShell scripts designed to streamline the authentication process for AWS services like CodeArtifact and ECR. These scripts will help you log into each service and update necessary tokens or credentials, with detailed logging for easy auditing and troubleshooting.

## Features

- Authenticate and log into AWS CodeArtifact repositories.
- Authenticate Docker with AWS ECR.
- Cross-platform compatibility (Windows, macOS, and Linux).

## Prerequisites

- AWS CLI installed and configured. For more information, refer to the [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) and [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).
- Docker installed (for ECR authentication).
- PowerShell Core (7.x) installed.
- Access to the AWS CodeArtifact and ECR services.
- Proper configuration of AWS credentials and region.

## Installation

1. Clone or download the repository containing the scripts.

## Usage

### Refresh NuGet Tokens for AWS CodeArtifact

1. Open PowerShell Core and navigate to the directory containing the `refreshNugetToken.ps1` script.
2. Run the script using the following command:
    ```powershell
    .\refreshNugetToken.ps1
    ````
3. To view the help message, use the following command: ``.\refreshNugetToken.ps1 -help``

4. Optional parameters:

    ``-RegionFallback``: Specify a fallback region (e.g., ``us-east-1``) if the AWS CLI region is not configured.
    ``-DEBUG:`` Enable debug mode for more detailed logs.
    Example:

    ```` pwsh
    .\refreshNugetToken.ps1 -RegionFallback "eu-west-1" -DEBUG $true
    ````


### Authenticate Docker with AWS ECR

1. Open PowerShell Core and navigate to the directory containing the `refreshEcrDockerToken.ps1` script.
2. Run the script using the following command:
    ```powershell
    .\refreshEcrDockerToken.ps1
    ```
3. To view the help message, use the following command: ``.\refreshEcrDockerToken.ps1 -help``

4. Optional parameters:

    ``-RegionFallback``: Specify a fallback region (e.g., ``us-east-1``) if the AWS CLI region is not configured.
    Example:

    ```` pwsh
    .\refreshEcrDockerToken.ps1 -RegionFallback "eu-west-1"
    ````


### Automate with Cron Jobs or Task Scheduler 

To ensure that your development machine is always authenticated with the necessary services, feel free to add these scripts to your cron jobs (Linux/macOS) or Task Scheduler (Windows). This way, you can automate the authentication process to run at startup or at regular intervals. 

#### Cron Job Example (Linux/macOS)

1. Open your crontab configuration:    

```sh    
crontab -e    
```

2. Add the following line to run the script at startup (adjust the path as needed):    

```sh    
@reboot pwsh /path/to/the/repository/refreshNugetTokens.ps1    
@reboot pwsh /path/to/the/repository/refreshEcrDockerToken.ps1    
```

#### Task Scheduler Example (Windows) 
1. Open Task Scheduler and create a new task. 

2. Set the trigger to run the task at login. 

3. Set the action to start a program and use the following settings: 

    `"pwsh C:\path\to\the\repository\refreshNugetTokens.ps1"`

4. same for the other scripts if you need it.



## Adding More Authentication Mechanisms

Currently, this repository includes authentication scripts for AWS CodeArtifact and AWS ECR. If you have other authentication mechanisms to add, feel free to contribute!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Hi, I'm Karim Zouine, the developer of these scripts. Contributions are very welcome! If you have suggestions, improvements, or bug fixes, please open an issue or submit a pull request. Let's make this project even better together!
