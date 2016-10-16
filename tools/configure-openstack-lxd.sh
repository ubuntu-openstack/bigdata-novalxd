#!/bin/bash

set -ex

. ./profiles/common

install_packages

# Set network defaults, if not already set.
[[ -z "$GATEWAY" ]] && export GATEWAY="10.245.168.1"
[[ -z "$CIDR_EXT" ]] && export CIDR_EXT="10.245.168.0/21"
[[ -z "$FIP_RANGE" ]] && export FIP_RANGE="10.245.171.0:10.245.175.254"
[[ -z "$NAMESERVER" ]] && export NAMESERVER="10.245.168.2"
[[ -z "$CIDR_PRIV" ]] && export CIDR_PRIV="172.16.0.0/12"
[[ -z "$SWIFT_IP" ]] && export SWIFT_IP="10.245.161.162"

# Configure neutron networking on overcloud
source novarc
./bin/neutron-ext-net --network-type flat -g $GATEWAY -c $CIDR_EXT -f $FIP_RANGE ext_net
./bin/neutron-tenant-net --network-type gre -t admin -r provider-router -N $NAMESERVER private $CIDR_PRIV

upload_image cloudimages xenial xenial-server-cloudimg-amd64-root.tar.xz raw

image_id=$(openstack image list | grep xenial | awk '{ print $2 }')
image_alt_id=$(openstack image list | grep xenial | awk '{ print $2 }')

create_tempest_users

access=$(openstack --os-username demo --os-password pass --os-tenant-name demo ec2 credentials create | grep access | awk '{ print $4 }')
secret=$(openstack ec2 credentials show $access | grep secret | awk '{ print $4 }')

create_tempest_flavors

function create_exclusive_aggregate {
    exclusive_flavor=$1
    app_hostnames=$(./bin/application-hostnames nova-compute-exclusive-${exclusiveflavor})
    if [ -n "$app_hostnames" ]; then
        aggregate_name=exclusive-lxd-${exclusive_flavor}
        openstack aggregate show ${aggregate_name} || {
            openstack aggregate create ${aggregate_name}
            openstack aggregate set --property exclusive-flavor=${exclusive_flavor} ${aggregate_name}
            openstack aggregate set --property max_instances_per_host=1 ${aggregate_name}
            for hostname in ${app_hostnames}; do
                openstack aggregate add host ${aggregate_name} ${hostname}
            done
        }
    fi
}

function create_exclusive_flavor {
    exclusive_flavor=$1
    case ${exclusive_flavor} in
        white)
            ram=32001
            cpu=4
            disk=300
            ;;
        grey)
            ram=32002
            cpu=4
            disk=300
            ;;
        orange)
            ram=32003
            cpu=4
            disk=300
            ;;
        aubergine)
            ram=32004
            cpu=4
            disk=300
            ;;
    esac
    flavor_name=e1.lxd.${exclusive_flavor}
    openstack flavor show ${flavor_name} || {
        openstack flavor create --public --ram ${ram} --disk ${disk} --vcpus ${cpu} ${flavor_name}
        openstack flavor set --property aggregate_instance_extra_specs:exclusive-flavor=${exclusive_flavor} ${flavor_name}
    }
}

for exclusive_flavor in white grey orange aubergine; do
    create_exclusive_aggregate ${exclusive_flavor}
    create_exclusive_flavor ${exclusive_flavor}
done
