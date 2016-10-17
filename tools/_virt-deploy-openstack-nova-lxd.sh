#!/bin/bash -e
#
# NOT FOR DEMO - NOT FOR METAL - a dev bundle for virtual deploys.
# Useful to confirm exclusive machine scheduling, etc.
#
# Remove maas tags, remove placement, set instance memory constraint
# and instance block device.  Then, deploy OpenStack Nova-LXD.

tmp_bundle_openstack=$(mktemp)

sed -e "s/ tags=demo//g" juju-bundles/openstack-nova-lxd.yaml > $tmp_bundle_openstack
sed -e "/    to:/d" -i $tmp_bundle_openstack
sed -e "/    -/d" -i $tmp_bundle_openstack
sed -e "s/sdb/vdb/g" -i $tmp_bundle_openstack
sed -e "s/mem=49152M/mem=3072M/g" -i $tmp_bundle_openstack

# Gather additional tools and repos before deploy
  # juju-wait:  this plugin can also be used as a stand-alone command line tool
  if [[ ! -d "$HOME/tools/juju-wait" ]]; then
    mkdir -vp $HOME/tools/
    git clone https://git.launchpad.net/juju-wait $HOME/tools/juju-wait
  fi

  # juju-deployer:  Build a venv with juju-deployer from trunk
  tox
  . .tox/deployer/bin/activate

# Deploy OpenStack Nova-LXD
# Wait for deployment to complete [relations and hooks must settle before proceeding]
echo "tmp_bundle_openstack: $tmp_bundle_openstack"

time juju bootstrap ||:
time juju-deployer -Svdc $tmp_bundle_openstack
time timeout 1800 $HOME/tools/juju-wait/juju-wait -v

# Confirm basic OpenStack API health via command line clients
./tools/check-openstack-api-clients.sh

# Configure OpenStack:  Tenant, Network, Images, Security Groups
./tools/configure-openstack-lxd.sh

# Launch and confirm a bastion instance
./tools/create-bastion.sh

# Announce OpenStack Dashboard and Juju GUI Addresses
