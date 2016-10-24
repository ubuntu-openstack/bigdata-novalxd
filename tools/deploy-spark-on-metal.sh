#!/bin/bash -e
# Build venv with juju-deployer from trunk, deploy
tox
. .tox/deployer/bin/activate
time juju bootstrap --constraints "arch=amd64 tags=demo" ||:
time juju-deployer -Svdc juju-bundles/magpie-metal.yaml
time juju-deployer -vdc juju-bundles/spark-hadoop-processing.yaml
time host $(juju-deployer -f resourcemanager)
