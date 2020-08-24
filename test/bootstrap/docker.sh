#!/bin/bash -e
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates software-properties-common
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual

curl -sSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install -y docker-ce
sudo service docker start

# Install docker: prepare for OpenShift
sudo sed -i 's/ExecStart=\(.*\)/ExecStart=\1 --insecure-registry 172.30.0.0\/16/' /lib/systemd/system/docker.service
sudo sed -i 's/SocketMode=\(.*\)/SocketMode=0666/' /lib/systemd/system/docker.socket
sudo systemctl daemon-reload
sudo systemctl restart docker