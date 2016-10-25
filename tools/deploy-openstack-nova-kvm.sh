#!/bin/bash -e
#
# Depoy OpenStack Nova-KVM

# Gather additional tools and repos before deploy
  # juju-wait:  this plugin can also be used as a stand-alone command line tool
  if [[ ! -d "$HOME/tools/juju-wait" ]]; then
    mkdir -vp $HOME/tools/
    git clone https://git.launchpad.net/juju-wait $HOME/tools/juju-wait
  fi

  # juju-deployer:  Build a venv with juju-deployer from trunk
  tox
  . .tox/deployer/bin/activate

# Deploy OpenStack Nova-KVM (after Magpie infrastructure validation)
# Wait for deployment to complete [relations and hooks must settle before proceeding]
time juju bootstrap --constraints "arch=amd64 tags=demo" ||:
time juju-deployer -Svdc juju-bundles/magpie-metal.yaml
time timeout 1800 $HOME/tools/juju-wait/juju-wait -v


exit 0


time juju-deployer -Svdc juju-bundles/openstack-nova-kvm.yaml
time timeout 2700 $HOME/tools/juju-wait/juju-wait -v

# Confirm basic OpenStack API health via command line clients
time ./tools/check-openstack-api-clients.sh

# Configure OpenStack:  Tenant, Network, Images, Security Groups
time ./tools/configure-openstack-kvm.sh

# Launch and confirm a bastion instance
time ./tools/create-bastion.sh
time ./tools/check-exclusive-instances.sh

# Announce OpenStack Dashboard and Juju GUI Addresses
