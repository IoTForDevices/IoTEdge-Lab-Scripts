#!/bin/bash

# Set Environment Variables (default names) for the Resource Group,
# Location, IoT Hub and the Virtual Machine Name
AZ_RG="IoTEdgeLab-RG"
AZ_EDGE_VM="IoTEdgeVM"
AZ_EDGE_DEV_VM="IoTEdgeDevVM"
AZ_EDGE_ID="MyIoTEdgeDevice"
AZ_LOC="westeurope"
AZ_IOTHUB="IoTHub-MST-20180710"

# Check if the user wants to override one or more of the default values
OPTS=`getopt -n 'parse-options' -o g:l:i:t:d: --long resource-group:,location:,iothub-name:,target-vm-name:,dev-vm-name: -- "$@"`
eval set -- "$OPTS"

#extract options and their arguments into variables
while true ; do
        case "$1" in
                -g | --resource-group ) AZ_RG="$2"; shift 2 ;;
                -l | --location       ) AZ_LOC="$2"; shift 2 ;;
                -i | --iothub-name    ) AZ_IOTHUB="$2"; shift 2 ;;
                -t | --target-vm-name ) AZ_EDGE_VM="$2"; shift 2 ;;
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
        echo "Creating a new Azure Resource Group"
        az group create --name $AZ_RG --location $AZ_LOC
fi

# Create a VM with an Ubuntu image
az vm create -g $AZ_RG -n $AZ_EDGE_VM --image Canonical:UbuntuServer:16.04-LTS:latest --generate-ssh-keys --size Standard_B1ms

# Create an IoTHub (if you don't want to use an existing IoTHub) and register your IoTEdge device
# TODO: Add switch to create or use existing
az iot hub create -g $AZ_RG -n $AZ_IOTHUB --sku S1
az iot hub device-identity create -n $AZ_IOTHUB -d $AZ_EDGE_ID -ee
IOTEDGE_DEVICE_CS=$(az iot hub device-identity show-connection-string -d $AZ_EDGE_ID -n $AZ_IOTHUB -o tsv)

az vm wait -g $AZ_RG -n $AZ_EDGE_VM --created

# Get VM information with queries and set environment variables with (virtual) network info
NIC_ID=$(az vm show -g $AZ_RG -n $AZ_EDGE_VM --query 'networkProfile.networkInterfaces[].id' -o tsv)

read -d '' IP_ID SUBNET_ID <<< $(az network nic show \
--ids $NIC_ID -g $AZ_RG --query '[ipConfigurations[].publicIpAddress.id, ipConfigurations[].subnet.id]' -o tsv)

IOTEDGEVM_IP_ADDR=$(az network public-ip show --ids $IP_ID -g $AZ_RG --query ipAddress -o tsv)

# Create a Windows VM for Azure IoT Edge Module Development
AZ_IMAGE=$(az vm image list -p MicrosoftWindowsDesktop -s rs4-pron --all --query \
        "[?offer=='Windows-10'].urn" -o tsv | sort -u | tail -n 1)
az vm create -g $AZ_RG -n $AZ_EDGE_DEV_VM --image $AZ_IMAGE --size Standard_D2s_v3 --subnet $SUBNET_ID --admin-password $DEV_PASSWORD --no-wait

# Install IoTEdge runtime on the newly created Azure IoT Edge Device and switch to the device
ssh $IOTEDGEVM_IP_ADDR 'bash -s' < ./install-IoTEdgeRuntime.sh "'$IOTEDGE_DEVICE_CS'"

ssh $IOTEDGEVM_IP_ADDR

