#!/bin/bash -ex
net_id="$(openstack network list | awk '/private/ {print $2}')"
openstack server create --image xenial --flavor e1.lxd.orange --key-name mykey --nic net-id=${net_id} --min 2 --max 2 --wait xenial-orange-check
openstack server create --image xenial --flavor e1.lxd.grey --key-name mykey --nic net-id=${net_id} --min 2 --max 2 --wait xenial-grey-check
openstack server list
for i in $(openstack server list | egrep "xenial-grey-check|xenial-orange-check" | awk '{ print $2 }'); do echo $i; openstack server delete --wait $i; done
openstack server list
