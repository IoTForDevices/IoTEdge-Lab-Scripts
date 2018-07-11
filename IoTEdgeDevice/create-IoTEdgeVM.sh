#!/bin/bash

# Create a new group, just for demo purpose
az group create --name IoTEdgeLab-RG --location westeurope

# Create a VM with an Ubuntu image
az vm create -g IoTEdgeLab-RG -n IoTEdgeVM --image Canonical:UbuntuServer:16.04-LTS:latest --generate-ssh-keys --size Standard_B1ms --no-wait

# Create an IoTHub (if you don't want to use an existing IoTHub) and register your IoTEdge device
# TODO: Add switch to create or use existing
az iot hub create -g IoTEdgeLab-RG -n IoTHub-MST-20180710 --sku S1
az iot hub device-identity create -n IoTHub-MST-20180710 -d MyIoTEdgeDevice -ee
IOTEDGE_DEVICE_CS=$(az iot hub device-identity show-connection-string -d MyIoTEdgeDevice -n IoTHub-MST-20180710 -o tsv)

az vm wait -g IoTEdgeLab-RG -n IoTEdgeVM --created

# Get VM information with queries and set environment variables with (virtual) network info
NIC_ID=$(az vm show -n IotEdgeVM -g IoTEdgeLab-RG \
--query 'networkProfile.networkInterfaces[].id' -o tsv)

read -d '' IP_ID SUBNET_ID <<< $(az network nic show \
--ids $NIC_ID -g IoTEdgeLab-RG --query '[ipConfigurations[].publicIpAddress.id, ipConfigurations[].subnet.id]' -o tsv)

IOTEDGEVM_IP_ADDR=$(az network public-ip show --ids $IP_ID \
-g IoTEdgeLab-RG --query ipAddress -o tsv)

# Install IoTEdge runtime on the newly created Azure IoT Edge Device and switch to the device
ssh $IOTEDGEVM_IP_ADDR 'bash -s' < ./install-IoTEdgeRuntime.sh "'$IOTEDGE_DEVICE_CS'"

ssh $IOTEDGEVM_IP_ADDR

