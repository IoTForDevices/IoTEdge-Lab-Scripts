#!/bin/bash
# Script to remove all resources that were used for the Azure IoT Edge Lab

# Set Environment Variable (default name) for the Resource Group
AZ_RG="IoTEdgeLab-RG"

# Check if the user wants to override one or more of the default values
OPTS=`getopt -n 'parse-options' -o g: --long resource-group: -- "$@"`
eval set -- "$OPTS"

#extract options and their arguments into variables
while true ; do
        case "$1" in
                -g | --resource-group ) AZ_RG="$2"; shift 2 ;;
                --) shift; break ;;
                *) break;;
        esac
done

az group delete --name $AZ_RG --no-wait -y
az group wait --name $AZ_RG --deleted

