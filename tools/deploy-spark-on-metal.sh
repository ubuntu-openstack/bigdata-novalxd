#!/bin/bash -e
# Build venv with juju-deployer from trunk, deploy
tox
. .tox/deployer/bin/activate
juju bootstrap --constraints "arch=amd64 tags=demo" ||:
juju-deployer -vdc juju-bundles/spark-hadoop-processing.yaml
host $(juju-deployer -f resourcemanager)
