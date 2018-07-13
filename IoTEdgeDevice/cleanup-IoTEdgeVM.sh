#!/bin/bash

# Remove all resources that were used for the EdgeLab

# Set Environment Variable (default name) for the Resource Group
AZ_RG="IoTEdgeLab-RG"

az group delete --name $AZ_RG --no-wait -y
az group wait --name $AZ_RG --deleted

