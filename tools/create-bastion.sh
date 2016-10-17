#!/bin/bash -ex
openstack server show xenial-bastion || (
    net_id="$(openstack network list | awk '/private/ {print $2}')"
    openstack server create --image xenial-lxd --flavor m1.test --key-name mykey --nic net-id=${net_id} --wait xenial-bastion
)

./tools/float-all.sh
