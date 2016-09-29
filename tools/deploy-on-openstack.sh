#!/bin/bash

tmp_bundle=$(mktemp)
echo $tmp_bundle

# Untag machines for use with the Juju OpenStack provider
sed -e "s# tags=demo##g" juju-bundles/spark-hadoop-processing.yaml > $tmp_bundle

# Deploy
juju-deployer -vdc $tmp_bundle
