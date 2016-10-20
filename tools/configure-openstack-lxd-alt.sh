#!/bin/bash -ex
#
# An alternative extra scenario to enable packing multiple Hadoop
# compute slaves on nova-lxd units.

source tools/common
source novarc

delete_all_public_flavors
create_exclusive_flavor all.small 2048 2 20
create_exclusive_flavor all.medium 10240 2 80
create_exclusive_flavor all.large 20480 4 200

for exclusive_flavor in all.large all.medium all.small; do
    max_instances="999999"
    app_hostnames=$(openstack hypervisor list | grep "[0-9]" | awk '{ print $4 }')
    aggregate_name=exclusive-lxd-${exclusive_flavor}

    openstack aggregate show ${aggregate_name} || {
        openstack aggregate create ${aggregate_name}
        openstack aggregate set --property exclusive-flavor=${exclusive_flavor} ${aggregate_name}
        openstack aggregate set --property max_instances_per_host=$max_instances ${aggregate_name}
        for hostname in ${app_hostnames}; do
            openstack aggregate remove host exclusive-lxd-all ${hostname} ||:
            openstack aggregate remove host exclusive-lxd-all.small ${hostname} ||:
            openstack aggregate remove host exclusive-lxd-orange ${hostname} ||:
            openstack aggregate remove host exclusive-lxd-grey ${hostname} ||:
            openstack aggregate add host ${aggregate_name} ${hostname}
        done
    }
done
