# AWS Authentication PWSH Version 🚀

## Overview

Welcome to the AWS Authentication Scripts repository\! This project contains powerful and modular PowerShell scripts designed to **streamline and automate the authentication process** for key AWS services like **CodeArtifact** (for NuGet tokens) and **ECR** (for Docker credentials).

These scripts feature integrated **AWS SSO (Single Sign-On) support** and detailed logging for easy auditing and troubleshooting.

-----

## Features

  * ✅ **CodeArtifact:** Authenticate and refresh NuGet tokens for AWS CodeArtifact repositories.
  * ✅ **ECR:** Authenticate Docker with AWS ECR to push and pull images.
  * 🔑 **SSO Management:** Includes an `-SSO` switch to easily force an AWS SSO login when your session expires.
  * 🌐 **Portability:** Cross-platform compatible (Windows, macOS, and Linux) using PowerShell Core.

-----

## Prerequisites

Before running the scripts, ensure you have the following installed and configured:

  * **AWS CLI v2:** Installed and configured, typically utilizing an **SSO Profile** for authentication. Refer to the [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
  * **Docker:** Installed and running (required for ECR authentication).
  * **PowerShell Core (7.x+):** Installed as the execution environment.
  * **Access:** Proper IAM permissions for CodeArtifact (`codeartifact:*`) and ECR (`ecr:*`) services.

-----

## Usage

All scripts should be executed from PowerShell Core (`pwsh`). Use the `-SSO` switch whenever your session is expired or you need to ensure a fresh login.

### 1\. Refresh NuGet Tokens for AWS CodeArtifact

This script logs into your AWS CodeArtifact domain and updates your NuGet configuration with fresh authentication tokens.

  * **Script:** `refreshNugetToken.ps1`

| Command | Purpose |
| :--- | :--- |
| `.\refreshNugetToken.ps1` | **Standard Run.** Uses the existing AWS session/profile. |
| `.\refreshNugetToken.ps1 -SSO` | **Force Login.** Executes `aws sso login` before refreshing tokens. **Use this when your session expires.** |
| `.\refreshNugetToken.ps1 -RegionFallback "region"` | Specify a fallback region if the AWS CLI region is not configured (e.g., `"eu-west-1"`). |
| `.\refreshNugetToken.ps1 -DEBUG $true` | Enable debug mode for verbose output and detailed logs. |

-----

### 2\. Authenticate Docker with AWS ECR

This script retrieves a temporary authentication token from ECR and logs your local Docker client into the registry.

  * **Script:** `refreshEcrDockerToken.ps1`

| Command | Purpose |
| :--- | :--- |
| `.\refreshEcrDockerToken.ps1` | **Standard Run.** Uses the existing AWS session/profile. |
| `.\refreshEcrDockerToken.ps1 -SSO` | **Force Login.** Executes `aws sso login` before fetching ECR credentials. **Use this when your session expires.** |
| `.\refreshEcrDockerToken.ps1 -RegionFallback "region"` | Specify a fallback region (e.g., `"us-east-1"`). |
| `.\refreshEcrDockerToken.ps1 -AccountId 123456789012` | Provide the 12-digit AWS Account ID directly, skipping the `sts:GetCallerIdentity` check. |

-----

## Automate Session Refresh ⏰

To maintain continuous access without manual intervention, integrate these scripts into your system's scheduling tools.

### Cron Job Example (Linux/macOS)

This runs the scripts every time the system reboots, ensuring a fresh session at startup.

1.  Open your crontab configuration:

    ```sh
    crontab -e
    ```

2.  Add the following lines (adjust the path and ensure the `-SSO` flag is included if the session needs to be forced):

    ```sh
    # Run at system startup/reboot
    @reboot pwsh /path/to/the/repository/refreshNugetToken.ps1 -SSO
    @reboot pwsh /path/to/the/repository/refreshEcrDockerToken.ps1 -SSO
    ```

### Task Scheduler Example (Windows)

Use Task Scheduler to run the scripts automatically at user login.

1.  Open Task Scheduler and create a new task with a **Trigger** set to **At log on**.

2.  Set the **Action** to **Start a program** with the following details:

    | Script | Program/script | Add arguments (optional) |
    | :--- | :--- | :--- |
    | **NuGet** | `pwsh` | `-NoProfile -File "C:\path\to\repository\refreshNugetToken.ps1" -SSO` |
    | **ECR** | `pwsh` | `-NoProfile -File "C:\path\to\repository\refreshEcrDockerToken.ps1" -SSO` |

-----

## Contribution & License

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

## Contributing

Hi, I'm Karim Zouine, the developer of these scripts. Contributions are very welcome\! If you have suggestions, improvements, or bug fixes, please open an issue or submit a pull request. Let's make this project even better together\!