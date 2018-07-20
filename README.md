# IoTEdge-Lab-Scripts
A collection of bash scripts to run an IoTEdge Lab.
## Building the Lab Environment
These scripts can be used to quickly setup a number of virtual machines
- Windows Development VM with Visual Studio Code installed for IoT Edge Module Development
- IoT Edge Host VM, powered by Ubuntu 16.04 LTS

Order and usage of the different scripts:
1. **create-IoTEdgeVM.sh** - This script can be ran from any physical machine. It is used to create an Azure Virtual Machine that will be used as development machine. The following (optional) parameters can be passed:

   | parameter                                      | default value |
   |---                                             |---            |
   | --resource-group or -g [resource group name]   | IoTEdgeLab-RG |
   | --location or -l [azure location]              | westeurope    |
   | --dev-vm-name or -d [Development Machine Name] | IoTEdgeDevVM  |

1. **InstallWindowsComponents.ps1** - This script, like all the following scripts as well, must be executed on the newly created Azure Virtual Machine. It does not take parameters and installs the Hyper-V and Linux Subsystem on Windows components, followed by a restart. After restarting, Ubuntu 16.04 must be installed from the Windows Store to be able to run a bash shell.
1. **InstallEdgeDevTools.ps1** - This script installs all development tools that are needed to build IoT Edge Modules.
1. **install-azure-cli.sh** - This script must be executed from a bash shell. It installs the azure command line interface + azure cli extensions.
1. **create-IoTEdgeVM.sh** - This script will create an Azure Virtual Machine that will host a Linux based IoT Edge device. The OS that will be installed is the latest version of Ubuntu Server 16.04 LTS. The following (optional) parameters can be passed:

   | parameter                                        | default value   |
   |---                                               |---              |
   | --resource-group or -g [resource group name]     | IoTEdgeLab-RG   |
   | --location or -l [azure location]                | westeurope      |
   | --dev-vm-name or -d [Development Machine Name]   | IoTEdgeDevVM    |
   | --target-vm-name or -t [IoT Edge Device Name]    | IoTEdgeVM       |
   | --iothub-name or -i [IoT Hub Name]               | IoTHub-MST-$now |
   | --acr-name or -a [Azure Container Registry Name] | ACRMST$now      |

   This script will also call a script to remotely install the IoT Edge Runtime on the newly created virtual target machine.

The steps to create a new IoT Edge Runtime are part of the script to build an IoT Edge Host VM or physical device. Those steps are described in this document: https://docs.microsoft.com/en-us/azure/iot-edge/quickstart-linux. The only thing you still need to do is to *Deploy a Module*, as described in the same document.

To be able to run the IoTEdge Lab, you also need an IoT Hub. For test purposes, a S1 IoT Hub is created under the same resource group as the virtual machines. To be able to host your own Azure IoT Edge modules, you also need an Azure Container Registry. As part of the scripts, a ACR basic SKU is also created.

   **NOTE:** If you want to save the modules that you create as part of this lab, make sure to specify a permanent ACR registry instead of building one as part of this lab.

All resources needed will be created in one single resource group. It is important to delete this resource group after being done with the lab. Otherwise you will continue to be charged for your VMs and for the IoT Hub. You can use the script **cleanup-IoTEdgeResources.sh** for this. This script cannot be executed from the Virtual Development machine, because that is one of the resources that will be removed by executing this script.

## Creating Filter Modules to deploy to your Edge Runtime

You will find sample code for two different filter modules, based on the following example: https://docs.microsoft.com/en-us/azure/iot-edge/tutorial-csharp-module in this repository. The following steps describe how to build these modules as part of the lab.

1. To create a filter module that sends an alert to an IoT Hub when the temperature exceeds a certain value, follow all the steps as described here: https://docs.microsoft.com/en-us/azure/iot-edge/tutorial-csharp-module#create-an-iot-edge-module-project.
1. As an additional exercise, you can create a second filter module in the same IoT Edge solution by right-clicking on the **modules** section in Visual Studio Code and selecting **Add IoT Edge Module**. Similar to the actions in step 1, give your new module an appropriate name. Our module will receive messages from the first module (all messages that don't raise temperature alerts) that will be send on to the IoT Hub, unless the humidity has a particular value.
   - In your new module, add a new device twin expected value called **Humidity** and give it a value.
   - Provide a callback that will be called when the device twin value has changed.
   - Change the FilterMessage callback in such a way that it filters out the specified **Humidity** value, passing all other messages on. You can use the following code as a hint:
   ```csharp
                if (messageBody != null && messageBody.ambient.humidity != humidityFilter)
                {
                    Console.WriteLine($"Sending message {counterValue} on to the IoTHub!");
                    var filteredMessage = new Message(messageBytes);
                    foreach (KeyValuePair<string, string> prop in message.Properties )
                    {
                        filteredMessage.Properties.Add(prop.Key, prop.Value);
                    }
                    await moduleClient.SendEventAsync("output1", filteredMessage);
                }
                else
                {
                    Console.WriteLine($"Filter out messages with humidity: {humidityFilter}");
                }

                // Indicate that the message treatment is completed
                return MessageResponse.Completed;
   ```
   - To receive messages, the original filter module that filters temperatures needs to be extended in a simular way. You can use the following code as a hint:
   ```csharp
                // Get the message body
                var messageBody = JsonConvert.DeserializeObject<MessageBody>(messageString);

                if (messageBody != null && messageBody.machine.temperature > temperatureThreshold)
                {
                    Console.WriteLine($"Machine temperature {messageBody.machine.temperature} exceeds threshold {temperatureThreshold}");
                    var filteredMessage = new Message(messageBytes);
                    foreach (KeyValuePair<string, string> prop in message.Properties )
                    {
                        filteredMessage.Properties.Add(prop.Key, prop.Value);
                    }
                    filteredMessage.Properties.Add("MessageType", "Alert");
                    await moduleClient.SendEventAsync("output1", filteredMessage);
                }
                else
                {
                    Console.WriteLine($"Sending message {counterValue} on to the next Module!");
                    var filteredMessage = new Message(messageBytes);
                    foreach (KeyValuePair<string, string> prop in message.Properties )
                    {
                        filteredMessage.Properties.Add(prop.Key, prop.Value);
                    }
                    await moduleClient.SendEventAsync("output2", filteredMessage);
                }

                // Indicate that the message treatment is completed
                return MessageResponse.Completed;
   ```
1. As a final, but important step, you need to inform the IoT Edge runtime what route messages will have to take. This routing information is added to the edgeHub desired properties in the deployment.template.json. Be aware that the input and output names are critical and should match what you have in your source code. If you modified the original filter module as described above and added an additional filter module as described as well, this routing information will pass messages from the first filter module to either the IoT Hub or to the second filter module.
```json
    "$edgeHub": {
      "properties.desired": {
        "schemaVersion": "1.0",
        "routes": {
          "sensorToCSharpFilterModule": "FROM /messages/modules/tempSensor/outputs/temperatureOutput INTO BrokeredEndpoint(\"/modules/CSharpFilterModule/inputs/input1\")",
          "CSharpFilterModuleToIoTHub": "FROM /messages/modules/CSharpFilterModule/outputs/output1 INTO $upstream",
          "CSharpFilterModuleToCSharpHumidityFilter": "FROM /messages/modules/CSharpFilterModule/outputs/output2 Into BrokeredEndpoint(\"/modules/CSharpHumidityFilter/inputs/input1\")",
          "CSharpHumidityFilterToIoTHub": "FROM /messages/modules/CSharpHumidityFilter/outputs/* INTO $upstream"
        },
        "storeAndForwardConfiguration": {
          "timeToLiveSecs": 7200
        }
      }
    },
```

### Lab Pre-requisites:
- You must have a valid Azure Subscription
- You must have a development machine (Linux or Windows with a linux subsystem) available to creaate / remotely connect to a Windows Development VM that will be created as part of running the scripts.
