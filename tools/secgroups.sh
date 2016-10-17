#!/bin/bash -ex
# Set security group rules

for port in 22 80 443 8080 3128; do
    openstack security group rule create default --proto tcp --dst-port $port --src-ip 0.0.0.0/0 ||:
    openstack security group rule create default --proto tcp --dst-port $port --src-ip ::/0 ||:
done

openstack security group rule create default --proto icmp --src-ip 0.0.0.0/0 ||:
openstack security group rule create default --proto icmp --src-ip ::/0 ||:

openstack security group rule create default --proto udp --dst-port 53 --src-ip 0.0.0.0/0 ||:
openstack security group rule create default --proto udp --dst-port 53 --src-ip ::/0 ||:

openstack security group rule list
