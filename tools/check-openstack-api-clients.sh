#!/bin/bash -ex
# Expect all to exit zero

. novarc

openstack aggregate list
openstack catalog list

openstack token issue
openstack user list
openstack project list
openstack server list

openstack endpoint list
openstack service list
openstack flavor list
openstack compute service list
openstack compute agent list
openstack image list

openstack stack list

openstack hypervisor show 1
openstack hypervisor show 2
openstack hypervisor show 3
openstack hypervisor show 4
openstack hypervisor show 5
openstack hypervisor show 6
openstack hypervisor show 7
openstack hypervisor show 8
openstack hypervisor list
