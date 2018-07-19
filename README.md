# IoTEdge-Lab-Scripts
A collection of bash scripts to run an IoTEdge Lab.
These scripts can be used to quickly setup a number of virtual machines
- 1 Windows Development VM with Visual Studio Code installed for IoT Edge Module Development
- 1 IoT Edge Host VM, powered by Ubuntu 16.04 LTS

In addition, similar scripts are available to install the necessary tools on a physical IoT Edge demo device (Raspberry Pi).

The steps to create a new IoT Edge Runtime are part of the script to build an IoT Edge Host VM or physical device. Those steps are described in this document: https://docs.microsoft.com/en-us/azure/iot-edge/quickstart-linux. The only thing you still need to do is to **Deploy a Module**, as described in the same document.

You will also find sample code for a filter module, based on the following example: https://docs.microsoft.com/en-us/azure/iot-edge/tutorial-csharp-module. 

To be able to run the IoTEdge Lab, you also need an IoT Hub. For test purposes, a S1 IoT Hub is created under the same resource group as the virtual machines. To be able to host your own Azure IoT Edge modules, you also need an Azure Container Registry. As part of the scripts, a ACR basic SKU is also created.
All resources needed will be created in one single resource group. It is important to delete this resource group after being done with the lab. Otherwise you will continue to be charged for your VMs and for the IoT Hub.

Pre-requisites:
- You must have a valid Azure Subscription
- You must have a development machine (Linux or Windows with a linux subsystem) available to creaate / remotely connect to a Windows Development VM that will be created as part of running the scripts.
