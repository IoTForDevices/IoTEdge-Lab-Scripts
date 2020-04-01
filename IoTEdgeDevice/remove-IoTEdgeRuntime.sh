sudo apt-get remove --purge iotedge

sudo docker ps -a

#the next should be depending on the modules returned by the statement above.
sudo docker rm -f tempSensor
sudo docker rm -f edgeHub
sudo docker rm -f edgeAgent
