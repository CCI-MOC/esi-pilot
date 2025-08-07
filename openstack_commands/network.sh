#!/bin/sh

# provisioning network
openstack network create --provider-network-type vlan --provider-segment 623 --provider-physical-network datacentre --share provisioning
openstack subnet create \
      --network provisioning \
      --subnet-range 192.168.11.0/24  \
      --ip-version 4 \
      --gateway 192.168.11.254 \
      --allocation-pool start=192.168.11.11,end=192.168.11.245 \
      --dns-nameserver 8.8.8.8 \
      --dhcp subnet-provisioning

# ctlplane network
openstack network create --provider-network-type flat --provider-physical-network  datacentre ctlplane
openstack subnet create --network ctlplane --subnet-range 192.168.24.0/24  --ip-version 4 --gateway 192.168.24.254 --no-dhcp ctlplane-subnet

# storage network
openstack network create --provider-network-type vlan --provider-segment 213 --provider-physical-network datacentre  --share storage
openstack subnet create \
          --network storage \
          --subnet-range 10.21.0.0/22  \
          --ip-version 4 \
          --gateway 10.21.0.1 \
          --allocation-pool start=10.21.0.140,end=10.21.0.159 \
          --dns-nameserver 8.8.8.8 \
          --dhcp subnet-storage

# external network
openstack network create --provider-network-type vlan --provider-segment 3801 --provider-physical-network datacentre  --external --share external
openstack subnet create \
          --network external \
          --subnet-range 128.31.20.0/22  \
          --ip-version 4 \
          --gateway 128.31.20.1 \
          --allocation-pool start=128.31.20.31,end=128.31.20.240 \
          --dns-nameserver 8.8.8.8 \
          --dhcp subnet-external

# NESE storage network
openstack network create --provider-network-type vlan --provider-segment 211 --provider-physical-network datacentre  --share nese-storage
openstack subnet create \
          --network nese-storage \
          --subnet-range 10.0.120.0/22  \
          --ip-version 4 \
          --no-dhcp \
          subnet-nese-storage

# provisioning router
openstack router create provisionrouter
openstack router add subnet provisionrouter subnet-provisioning
openstack router add subnet provisionrouter ctlplane-subnet
openstack router add subnet provisionrouter subnet-storage
openstack router set --external-gateway external provisionrouter
