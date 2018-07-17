# PowerShell script to install Visual Studio Code, .NET Core 2.1, Docker CE for Windows and GitHub for Windows

$VSCodeInstallFile=$destinationFolder+"\vscode.exe"
#$GitHubWinInstallFile=$destinationFolder+"\github.exe"
$NetCoreInstaller=$destinationFolder+"\netcore.exe"
$DockerInstallFile=$destinationFolder+"\dockerwin.exe"

$VSCodeUri="https://go.microsoft.com/fwlink/?Linkid=852157"
$GitHubWinUri="https://central.github.com/deployments/desktop/desktop/latest/win32"
$NetCoreUri="https://download.microsoft.com/download/4/0/9/40920432-3302-47a8-b13c-bbc4848ad114/dotnet-sdk-2.1.302-win-x64.exe"
$DockerUri="https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe"

# Download pre-requisites
Start-BitsTransfer -Source $VSCodeUri -Destination $VSCodeInstallFile
#Start-BitsTransfer -Source $GitHubWinUri -Destination $GitHubWinInstallFile
Start-BitsTransfer -Source $NetCoreUri -Destination $NetCoreInstaller
Start-BitsTransfer -Source $DockerUri -Destination $DockerInstallFile

# Install pre-requisites

# Add Visual Studio Code extensions
code --install-extension ms-v

