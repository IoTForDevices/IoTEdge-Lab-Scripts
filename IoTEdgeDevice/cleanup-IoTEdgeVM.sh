#!/bin/bash

# Remove all VMs that were used for the EdgeLab

az group delete --name IoTEdgeLab-RG --no-wait -y
az group wait --name IoTEdgeLab-RG --deleted

