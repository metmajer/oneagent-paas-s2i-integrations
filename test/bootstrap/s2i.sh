#!/bin/bash -e

# Install s2i to /usr/bin
curl -sSL https://github.com/openshift/source-to-image/releases/download/v1.1.5/source-to-image-v1.1.5-4dd7721-linux-amd64.tar.gz > /tmp/s2i-linux.tar.gz
sudo tar xvzf /tmp/s2i-linux.tar.gz -C /usr/bin ./s2i