# Script to install hyper-v and linux-subsystem

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
Enable-WIndowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
