#!/bin/bash

if [ $# != 1 ]
then
	echo Usage: A single argument containing the IoT Edge Device connection string
	exit
fi

# Register your device to use the IoT Edge runtime software repository
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > ./microsoft-prod.list
sudo cp ./microsoft-prod.list /etc/apt/sources.list.d/

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo cp ./microsoft.gpg /etc/apt/trusted.gpg.d/

# Install a container runtime
sudo apt-get update
sudo apt-get install moby-engine -y
sudo apt-get install moby cli -y

#install and configure the IoT Edge security daemon
sudo apt-get update
sudo apt-get install iotedge -y

sudo sed -i -e "s|<ADD DEVICE CONNECTION STRING HERE>|$1|" /etc/iotedge/config.yaml

sudo systemctl restart iotedge
sudo iotedge list
