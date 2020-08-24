#!/bin/bash -e
ME=$(dirname $0)
. $ME/data/test/bootstrap/base.sh
. $ME/data/test/bootstrap/docker.sh
#. $ME/data/test/bootstrap/openshift.sh
. $ME/data/test/bootstrap/s2i.sh

# Install s2i-wildfly
curl -sL https://github.com/openshift-s2i/s2i-wildfly/archive/master.zip > /tmp/s2i-wildfly.zip
unzip /tmp/s2i-wildfly.zip -d /opt
mv /opt/s2i-wildfly-master /opt/s2i-wildfly