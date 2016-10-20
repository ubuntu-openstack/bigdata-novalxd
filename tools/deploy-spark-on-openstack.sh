#!/bin/bash -e
# Build venv with juju-deployer from trunk, deploy
source novarc
tmp_bundle=$(mktemp)
tox
. .tox/deployer/bin/activate
juju bootstrap ||:
juju-deployer -vdc juju-bundles/spark-hadoop-processing-on-openstack.yaml
tools/float-all.sh
tools/float-namenode.sh
