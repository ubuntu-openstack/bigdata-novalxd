#!/bin/bash -e
#
# NOT FOR DEMO - just a virtual deploy to check for unit placement accuracy.
#
# Remove maas tags, then deploy magpie, then openstack.
# Not expected to quiesce, just check for placement visually.
tmp_bundle_openstack=$(mktemp)
tmp_bundle_magpie=$(mktemp)
sed -e "s# tags=demo##g" juju-bundles/openstack-nova-lxd.yaml > $tmp_bundle_openstack
sed -e "s# tags=demo##g" juju-bundles/magpie-metal.yaml > $tmp_bundle_magpie
tox
. .tox/deployer/bin/activate
juju bootstrap ||:
juju-deployer -Svdc $tmp_bundle_magpie
#sleep 120 # Don't do this type of sleep thing for real deploys.  It will race.
sleep 30
juju-deployer -Svdc $tmp_bundle_openstack
