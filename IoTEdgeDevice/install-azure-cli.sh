#!/bin/bash

# This script is used to install the Azure CLI 2.x on your development machine.
# This is needed to use the development machine to automatically build a (virtual) Linux based IoT Edge target

# Modify the sources list
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

# Get the Microsoft signing key
curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Install the CLI
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install azure-cli

az extension add --name azure-cli-iot-ext

