#!/bin/bash -e
# Untag bundle, build venv with juju-deployer from trunk, deploy
tmp_bundle=$(mktemp)
sed -e "s# tags=demo##g" juju-bundles/spark-hadoop-processing.yaml > $tmp_bundle
tox
. .tox/deployer/bin/activate
juju bootstrap ||:
juju-deployer -vdc $tmp_bundle
tools/float-namenode.sh
