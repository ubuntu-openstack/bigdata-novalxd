#!/bin/bash -e
# Launch multiple instances

instance_qty=$1
image_name=$2

if [ -z "$instance_qty" ]; then
  echo "Launches N quantity of XYZ instances."
  echo "Usage:  <this script> <qty of instances>"
  exit 1
fi
if [ -z "$image_name" ]; then
    image_name="xenial"
fi

net_id="$(openstack network list | awk '/private/ {print $2}')"
for m in $(seq 1 $instance_qty); do
  server_name="${image_name}$(date +'%H%M%S')"
  echo ${server_name} ${p_name} ${net_id}
  openstack server create --image $image_name --flavor m1.test --key-name mykey --nic net-id=${net_id} $server_name
done
