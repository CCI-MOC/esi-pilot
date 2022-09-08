#!/bin/sh
cd /home/stack/images/image-wallaby
openstack image create   --container-format ari   --disk-format ari   --public   --file ironic-python-agent.initramfs centos-8-deploy-ramdisk
openstack image create   --container-format aki   --disk-format aki   --public   --file ironic-python-agent.kernel centos-8-deploy-kernel

#user image
cd /home/stack/images/image-provisioning
KERNEL_ID=$(openstack image create \
  --file centos.vmlinuz --public \
  --container-format aki --disk-format aki \
  -f value -c id centos.vmlinuz)

RAMDISK_ID=$(openstack image create \
  --file centos.initrd --public \
  --container-format ari --disk-format ari \
  -f value -c id centos.initrd)

openstack image create \
  --file centos.qcow2 \
  --public \
  --container-format bare \
  --disk-format qcow2 \
  --property kernel_id=$KERNEL_ID \
  --property ramdisk_id=$RAMDISK_ID \
  centos-image
