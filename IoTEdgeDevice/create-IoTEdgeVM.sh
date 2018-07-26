#!/bin/bash
# This script creates a Linux powered target VM for an IoT Edge Device
# It also creates an IoTHub and an Azure Container Registry

# Use this to get more debug info 'set -x'

now=$(date +"%Y%m%d")

# Set Environment Variables (default names) for the Resource Group,
# Location, IoT Hub and the Virtual Machine Name
AZ_RG="IoTEdgeLab-RG"
AZ_EDGE_VM="IoTEdgeVM"
AZ_EDGE_DEV_VM="IoTEdgeDevVM"
AZ_EDGE_ID="MyIoTEdgeDevice"
AZ_LOC="westeurope"
AZ_IOTHUB="IoTHub-MST-$now"
AZ_ACR="ACRMST$now"

# Check if the user wants to override one or more of the default values
OPTS=`getopt -n 'parse-options' -o g:l:i:t:d:a: --long resource-group:,location:,iothub-name:,target-vm-name:,dev-vm-name:,acr-name: -- "$@"`
eval set -- "$OPTS"

#extract options and their arguments into variables
while true ; do
        case "$1" in
                -g | --resource-group ) AZ_RG="$2"; shift 2 ;;
                -l | --location       ) AZ_LOC="$2"; shift 2 ;;
                -i | --iothub-name    ) AZ_IOTHUB="$2"; shift 2 ;;
                -t | --target-vm-name ) AZ_EDGE_VM="$2"; shift 2 ;;
                -d | --dev-vm-name    ) AZ_EDGE_DEV_VM="$2"; shift 2 ;;
                -a | --acr-name       ) AZ_ACR="$2"; shift 2 ;;
                --) shift; break ;;
                *) break;;
        esac
done

echo "Creating $AZ_EDGE_DEV_VM in resource group $AZ_RG"
echo "Using the following IoTHub: $AZ_IOTHUB and ACR: $AZ_ACR"

# Verify if the group already exists, if not: Create a new group, just for demo purpose
AZ_GROUP=$(az group exists -n $AZ_RG)
if [ $AZ_GROUP != true ]
then
        echo "Creating a new Azure Resource Group"
        az group create --name $AZ_RG --location $AZ_LOC
fi

# Get VM information for the development machine with queries and store (virtual) network info
NIC_ID_DEV=$(az vm show -g $AZ_RG -n $AZ_EDGE_DEV_VM --query 'networkProfile.networkInterfaces[].id' -o tsv)

SUBNET_ID=$(az network nic show --ids $NIC_ID_DEV -g $AZ_RG --query 'ipConfigurations[].subnet.id' -o tsv)

# Create a VM with an Ubuntu image
echo "Creating a new Virtual Machine: $AZ_EDGE_VM connected to subnet: $SUBNET_ID"
az vm create -g $AZ_RG -n $AZ_EDGE_VM --image Canonical:UbuntuServer:16.04-LTS:latest --subnet $SUBNET_ID --generate-ssh-keys --size Standard_B1ms --no-wait

# Create an IoTHub (if you don't want to use an existing IoTHub)
IOTHUB_FOUND=$(az iot hub list --query "[?name=='$AZ_IOTHUB'].name" -o tsv)
if [ ! $IOTHUB_FOUND ]
then
	echo "Creating a new IoT Hub: $AZ_IOTHUB"
        az iot hub create -g $AZ_RG -n $AZ_IOTHUB --sku S1
fi

# Create an Azure IoT Edge Device Identity on your IoTHub if one does not yet exist
IOTEDGE_DEV_FOUND=$(az iot hub device-identity list -n $AZ_IOTHUB --query "[?deviceId=='$AZ_EDGE_ID'].capabilities.iotEdge" -o tsv)
if [ ! $IOTEDGE_DEV_FOUND ]
then
	echo "Creating a new IoT Edge Device Identity: $AZ_EDGE_ID on IoT Hub: $AZ_IOTHUB"
	az iot hub device-identity create -n $AZ_IOTHUB -d $AZ_EDGE_ID -ee
fi
IOTEDGE_DEVICE_CS=$(az iot hub device-identity show-connection-string -d $AZ_EDGE_ID -n $AZ_IOTHUB -o tsv)

# Create an Azure Container Registry if one does not yet exist
ACR_FOUND=$(az acr list --query "[?name=='$AZ_ACR'].name" -o tsv)
if [ ! $ACR_FOUND ]
then
	echo "Creating a new ACR: $AZ_ACR"
	az acr create -g $AZ_RG --name $AZ_ACR --ksu Basic
fi

# Wait for the IoT Edge target VM to be created
echo "Waiting until the Virtual Machine $AZ_EDGE_VM is created"
az vm wait -g $AZ_RG -n $AZ_EDGE_VM --created

# Get VM information with queries and set environment variables with (virtual) network info
NIC_ID_TARGET=$(az vm show -g $AZ_RG -n $AZ_EDGE_VM --query 'networkProfile.networkInterfaces[].id' -o tsv)

IP_ID=$(az network nic show --ids $NIC_ID_TARGET -g $AZ_RG --query 'ipConfigurations[].publicIpAddress.id' -o tsv)

IOTEDGEVM_IP_ADDR=$(az network public-ip show --ids $IP_ID -g $AZ_RG --query ipAddress -o tsv)

# Install IoTEdge runtime on the newly created Azure IoT Edge Device and switch to the device
ssh $IOTEDGEVM_IP_ADDR 'bash -s' < ./install-IoTEdgeRuntime.sh "'$IOTEDGE_DEVICE_CS'"

ssh $IOTEDGEVM_IP_ADDR

