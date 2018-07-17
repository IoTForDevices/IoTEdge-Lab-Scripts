#!/bin/bash
# Script to create an Azure Virtual Machine running Windows 10 for Azure IoT Edge Development
# This script can be executed on any physical machine that has an Internet connection
# Pre-requisites: az login has already been executed with a valid Azure subscription

# Set Environment Variables (default names) for the Resource Group, Location and the Virtual Dev Machine Name
AZ_RG="IoTEdgeLab-RG"
AZ_EDGE_DEV_VM="IoTEdgeDevVM"
AZ_LOC="westeurope"

# Check if the user wants to override one or more of the default values
OPTS=`getopt -n 'parse-options' -o g:l:d: --long resource-group:,location:,dev-vm-name: -- "$@"`
eval set -- "$OPTS"

#extract options and their arguments into variables
while true ; do
        case "$1" in
                -g | --resource-group ) AZ_RG="$2"; shift 2 ;;
                -l | --location       ) AZ_LOC="$2"; shift 2 ;;
                -d | --dev-vm-name    ) AZ_EDGE_DEV_VM="$2"; shift 2 ;;
                --) shift; break ;;
                *) break;;
        esac
done

# Set the password for the Windows Development VM
read -sp 'Development VM Password: ' DEV_PASSWORD
echo
read -sp 'Retype Development VM Password: ' DEV_PASSWORD1
echo
if [ $DEV_PASSWORD != $DEV_PASSWORD1 ]
then
        echo "Passwords not identical!"
        exit 1
fi

# Verify if the group already exists, if not: Create a new group, just for demo purpose
AZ_GROUP=$(az group exists -n $AZ_RG)
if [ $AZ_GROUP != true ]
then
        echo "Creating a new Azure Resource Group ..."
        az group create --name $AZ_RG --location $AZ_LOC
fi

# Create a Windows VM for Azure IoT Edge Module Development
echo "Find Windows 10 Image ..."
AZ_IMAGE=$(az vm image list -p MicrosoftWindowsDesktop -s rs4-pron --all --query \
        "[?offer=='Windows-10'].urn" -o tsv | sort -u -V | tail -n 1)

echo "Creating a new virtual machine with the following image: $AZ_IMAGE ..."
az vm create -g $AZ_RG -n $AZ_EDGE_DEV_VM --image $AZ_IMAGE --size Standard_D2s_v3 --admin-password $DEV_PASSWORD

# NOTE: On target, immediately after running this script, install Github for Windows
#       After that, clone the following repository: https://github.com/mstruys/IoTEdge-Lab-Scripts.git 
# 	Run the following PowerShell scripts to install additional Windows Components and development toolsh
#           InstallWindowsComponents.ps1
#           InstallEdgeDevTools.ps1
