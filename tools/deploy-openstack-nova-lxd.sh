#!/bin/bash -e
#
# Depoy OpenStack Nova-LXD

# Gather additional tools and repos before deploy
  # juju-wait:  this plugin can also be used as a stand-alone command line tool
  if [[ ! -d "$HOME/tools/juju-wait" ]]; then
    mkdir -vp $HOME/tools/
    git clone https://git.launchpad.net/juju-wait $HOME/tools/juju-wait
  fi

  # juju-deployer:  Build a venv with juju-deployer from trunk
  tox
  . .tox/deployer/bin/activate

# Deploy OpenStack Nova-LXD (after Magpie infrastructure validation)
# Wait for deployment to complete [relations and hooks must settle before proceeding]
juju bootstrap --constraints "arch=amd64 tags=demo" ||:
juju-deployer -Svdc juju-bundles/magpie-metal.yaml
timeout 1800 $HOME/tools/juju-wait/juju-wait -v
juju-deployer -Svdc juju-bundles/openstack-nova-lxd.yaml
timeout 2700 $HOME/tools/juju-wait/juju-wait -v

# Confirm basic OpenStack API health via command line clients
./tools/check-openstack-api-clients.sh

# Configure OpenStack:  Tenant, Network, Images, Security Groups
./tools/configure-openstack-lxd.sh

# Launch and confirm a bastion instance
./tools/create-bastion.sh

# Announce OpenStack Dashboard and Juju GUI Addresses
