#!/bin/bash -e

# First two octets of floating ip range
ip_f_str="10.245."
application="namenode"

function get_ip_f() {
  local var=$(nova floating-ip-list | grep '\-  ' | awk '{ print $4 }' | head -n 1)
  echo $var
}

# Get UUID of instance
unit_uuid=$(juju status --format=yaml $application | grep instance-id | awk '{ print $2 }')
if [ -z "$unit_uuid" ]; then
  echo "Couldn't get UUID for $application."
  exit 1
fi
echo "Unit uuid: $unit_uuid"

# Check for existing floating IP on instance
if [ ! -z "$(nova list | grep .*${unit_uuid}.*${ip_f_str})" ]; then
  echo "Instance already has floating IP."
  nova list | grep $unit_uuid
  exit 0
fi

# Get a free floating IP if available, create one if not.
ip_f=$(get_ip_f)
if [ -z "$ip_f" ]; then
  echo "Asking for a new floating IP."
  nova floating-ip-create
  ip_f=$(get_ip_f)
  if [ -z "$ip_f" ]; then
    echo "Couldn't get floating IP."
    exit 1
  fi
fi

# Associate the floating IP
nova floating-ip-associate $unit_uuid $ip_f
juju status --format=yaml $application
nova list | grep $unit_uuid
echo "Floating IP:  ${ip_f}"
