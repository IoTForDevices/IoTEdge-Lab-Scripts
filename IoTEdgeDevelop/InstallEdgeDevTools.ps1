# PowerShell script to install Visual Studio Code, .NET Core 2.1 and Docker CE for Windows

#Import-Module BitsTransfer
 
#$destinationFolder="c:\IoTEdgeReqs"
#if (-Not (Test-Path -Path $destinationFolder))
#{
#    New-Item -ItemType directory -Path $destinationFolder
#}

#$GitInstallExe=$destinationFolder+"\git.exe"
#$DockerInstallExe=$destinationFolder+"\dockerwin.exe"
#$VSCodeInstallExe=$destinationFolder+"\vscode.exe"
#$NetCoreInstallExe=$destinationFolder+"\netcore.exe"

#$GitUri="http://git-scm.com/download/win"
#$DockerUri="https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe"
#$VSCodeUri="https://go.microsoft.com/fwlink/?Linkid=852157"
#$NetCoreUri="https://download.microsoft.com/download/4/0/9/40920432-3302-47a8-b13c-bbc4848ad114/dotnet-sdk-2.1.302-win-x64.exe"

#Install Git, docker, visual studio code and dot net core 2.0 through the Chocolatey installer
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install git
choco install docker-for-windows
choco install dotnetcore-sdk 
choco install vscode
choco install vscode-csharp
choco install vscode-docker


# Download pre-requisites for Azure IoT Edge Module Development
#Start-BitsTransfer -Source $GitUri -Destination $GitInstallExe
#Start-BitsTransfer -Source $VSCodeUri -Destination $VSCodeInstallExe
#Start-BitsTransfer -Source $NetCoreUri -Destination $NetCoreInstallExe
#Start-BitsTransfer -Source $DockerUri -Destination $DockerInstallExe

# Install the tools
#& $GitInstallExe /SP /VerySilent | Out-Null
#& $VSCodeInstallExe /SP /VERYSILENT | Out-Null
#& $DockerInstallExe | Out-Null
#& $NetCoreInstallExe /quiet | Out-Null

# Add Visual Studio Code extensions
code --install-extension vsciot-vscode.azure-iot-edge
#code --install-extension ms-vscode.csharp
#code --install-extension peterjausovec.vscode-docker

