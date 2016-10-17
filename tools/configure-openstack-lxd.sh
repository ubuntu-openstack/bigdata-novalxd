#!/bin/bash -ex

source tools/common
install_packages
source novarc
./bin/neutron-ext-net --network-type flat -g $GATEWAY -c $CIDR_EXT -f $FIP_RANGE ext_net
./bin/neutron-tenant-net --network-type gre -t admin -r provider-router -N $NAMESERVER private $CIDR_PRIV

upload_image cloudimages xenial-lxd xenial-server-cloudimg-amd64-root.tar.xz raw lxc x86_64
create_demo_user
./quota-million.sh
./secgroups.sh

for exclusive_flavor in white grey orange aubergine; do
    create_exclusive_aggregate ${exclusive_flavor}
    create_exclusive_flavor ${exclusive_flavor}
done
