# PowerShell script to install Visual Studio Code, .NET Core 2.1 and Docker CE for Windows

#Install Git, docker, visual studio code and dot net core 2.0 through the Chocolatey installer
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

choco install git
choco install docker-for-windows
choco install dotnetcore-sdk 
choco install vscode
choco install vscode-csharp
choco install vscode-docker

# Make `refreshenv` available right away, by defining the $env:ChocolateyInstall variable
# and importing the Chocolatey profile module.
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

# refreshenv is now an alias for Update-SessionEnvironment
# (rather than invoking refreshenv.cmd, the *batch file* for use with cmd.exe)
# This should make code (Visual Studio Code) accessible via the refreshed $env:PATH, so that it can be 
# called by name only.
refreshenv

code --install-extension vsciot-vscode.azure-iot-edge

