@echo off
rem Sets the current directory to the location of this batch file
pushd "%~dp0"

echo.
echo ===================================================
echo   Starting AWS CodeArtifact NuGet Token Refresh
echo ===================================================
echo.

rem Executes the PowerShell script (pwsh is PowerShell Core)
rem The -SSO flag is included for the first run or if the token is known to be expired.
pwsh -NoProfile -ExecutionPolicy Bypass -File ".\refreshNugetToken.ps1" -SSO

if errorlevel 1 (
    echo.
    echo ERROR: The NuGet token refresh failed! Please check the logs and ensure AWS SSO login completed successfully.
) else (
    echo.
    echo SUCCESS: CodeArtifact NuGet tokens have been updated!
)

echo.
echo Press any key to exit...
pause > nul
popd