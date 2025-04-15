#!/bin/sh

# NERC 2176 routed network
openstack network create --provider-network-type vlan --provider-segment 2076 --provider-physical-network datacentre --project nerc-admins nerc-infra-routed
openstack subnet create \
          --network nerc-infra-routed \
          --subnet-range 10.85.0.0/22  \
          --ip-version 4 \
          --no-dhcp \
          subnet-nerc-infra-routed

# Unity 300 internal network
openstack network create --provider-network-type vlan --provider-segment 300 --provider-physical-network datacentre --project unity unity-internal

# IBMScale Highspeed network 2304
openstack network create --provider-network-type vlan --provider-segment 2304 --provider-physical-network datacentre --project ibmscale ibmscale-highspeed
