#!/bin/bash -e
# Launch multiple instances
p_qty=$1
if [ -z "$p_qty" ]; then
  echo "Launches N quantity of XYZ instances."
  echo "Usage:  <this script> <qty of instances>"
  exit 1
fi

net_id="$(openstack network list | awk '/private/ {print $2}')"
image_name="xenial-lxd"
for m in $(seq 1 $p_qty); do
  server_name="${image_name}$(date +'%H%M%S')"
  echo ${server_name} ${p_name} ${net_id}
  openstack server create --image $image_name --flavor m1.test --key-name mykey --nic net-id=${net_id} $server_name
done
