#!/bin/bash -ex
net_id="$(openstack network list | awk '/private/ {print $2}')"
openstack server create --image xenial --flavor e1.lxd.orange --key-name mykey --nic net-id=${net_id} --min 7 --max 7 --wait xenial-check
openstack server list
