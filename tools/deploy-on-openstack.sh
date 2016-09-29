#!/bin/bash

# Untag machines for use with the Juju OpenStack provider
sed -e "s# tags=demo##g" juju-bundles/spark-hadoop-processing.yaml -i

# Deploy
juju-deployer -vdc juju-bundles/spark-hadoop-processing.yaml
