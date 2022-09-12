#!/bin/sh

#volume image
cd /home/stack/
openstack image create --public --disk-format raw --container-format bare --file centos7-bootable centos7-bootable
openstack volume create volume-bootable-new --image centos7-bootable --bootable --size 40
