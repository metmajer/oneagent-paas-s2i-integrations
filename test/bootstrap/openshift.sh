#!/bin/bash -e
sudo apt-get update
sudo apt-get install -y socat

# Install oc to /usr/bin
curl -sSL https://github.com/openshift/origin/releases/download/v1.5.0-rc.0/openshift-origin-client-tools-v1.5.0-rc.0-49a4a7a-linux-64bit.tar.gz > /tmp/oc-linux.tar.gz
tar xvzf /tmp/oc-linux.tar.gz -C /tmp 
sudo mv /tmp/openshift-origin-client-tools-v1.5.0-rc.0-49a4a7a-linux-64bit/oc /usr/bin

# Run OpenShift
oc cluster up

# Copy admin.kubeconfig to ~/.kube/config to enable "oc login -u system:admin"
sudo cp /var/lib/origin/openshift.local.config/master/admin.kubeconfig ~/.kube/config
sudo chown "${USER}:${USER}" ~/.kube/config