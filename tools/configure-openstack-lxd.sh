#!/bin/bash -ex
source tools/common
install_packages
source novarc
#./bin/neutron-ext-net --network-type flat -g $GATEWAY -c $CIDR_EXT -f $FIP_RANGE ext_net
#./bin/neutron-tenant-net --network-type gre -t admin -r provider-router -N $NAMESERVER private $CIDR_PRIV

create_demo_user
create_keypairs
set_quotas
create_secgroup_rules
delete_all_public_flavors

upload_image cloudimages xenial-lxd xenial-server-cloudimg-amd64-root.tar.xz raw lxc x86_64
openstack flavor show m1.test || openstack flavor create --ram 2048 --disk 20 --vcpus 2 m1.test

for exclusive_flavor in white grey orange aubergine; do
    create_exclusive_aggregate ${exclusive_flavor}
    create_exclusive_flavor ${exclusive_flavor}
done

