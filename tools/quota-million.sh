#!/bin/bash -ex
# Set quotas to a ridiculous level for uninhibited testing

for tenant in admin demo; do
    TENANT_ID="$(keystone tenant-get admin | grep " id " | awk '{ print $4 }')"

    openstack quota set \
    --instances 999999 \
    --ram 999999 \
    --floating-ips 999999 \
    --fixed-ips 999999 \
    --cores 999999 \
    --key-pairs 999999 \
    --secgroups 999999 \
    --secgroup-rules 999999 \
    $TENANT_ID

    neutron quota-update \
    --network 999999 \
    --subnet 999999 \
    --port 999999 \
    --router 999999 \
    --floatingip 999999 \
    --security-group 999999 \
    --security-group-rule 999999 \
    --pool 999999 \
    --tenant-id $TENANT_ID
done
