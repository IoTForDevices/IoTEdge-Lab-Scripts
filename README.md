# IoTEdge-Lab-Scripts
A collection of bash scripts to run an IoTEdge Lab.
These scripts can be used to quickly setup a number of virtual machines
- 1 IoT Edge Host VM, powered by Ubuntu 16.04 LTS
- 1 Windows Development VM with Visual Studio Code installed for IoT Edge Module Development

To be able to run the IoTEdge Lab, you also need an IoT Hub. For test purposes, a S1 IoT Hub is created under the same resource group as the virtual machines.
It is important to delete the resource group after being done with the lab. Otherwise you will continue to be charged for your VMs and for the IoT Hub.

Pre-requisites:
- You must have a valid Azure Subscription
- You must have the latest az cli installed
- You must have the latest az iot extensions installed
- You must have a development machine (Linux or Windows with a linux subsystem) available.
