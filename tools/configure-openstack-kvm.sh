#!/bin/bash -ex
source tools/common
source novarc

./bin/neutron-ext-net --network-type flat -g $GATEWAY -c $CIDR_EXT -f $FIP_RANGE ext_net
./bin/neutron-tenant-net --network-type gre -t admin -r provider-router -N $NAMESERVER private $CIDR_PRIV

create_demo_user
create_keypairs
set_quotas
create_secgroup_rules
delete_all_public_flavors

upload_image cloudimages xenial xenial-server-cloudimg-amd64-disk1.img raw

create_exclusive_aggregate orange 1 kvm
create_exclusive_flavor orange 40960 8 416 kvm

create_exclusive_aggregate grey 999999 kvm
create_exclusive_flavor grey 2048 2 20 kvm

