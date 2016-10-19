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

upload_image cloudimages xenial xenial-server-cloudimg-amd64-root.tar.xz raw

create_exclusive_aggregate orange 1
create_exclusive_flavor orange 32768 300 4

create_exclusive_aggregate grey 999999
create_exclusive_flavor grey 2048 2 20

