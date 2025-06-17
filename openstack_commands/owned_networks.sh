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

# IBMScale Tenant Nets
openstack network create --provider-network-type vlan --provider-segment 2305 --provider-physical-network datacentre --project ibmscale ibmscale-tenant1
openstack subnet create \
          --network ibmscale-tenant1 \
          --subnet-range 10.8.0.0/18  \
          --ip-version 4 \
          --allocation-pool start=10.8.1.0,end=10.8.63.254 \
          --host-route destination=10.7.0.0/20,gateway=10.8.0.1 \
          --dhcp subnet-ibmscale-tenant1

openstack network create --provider-network-type vlan --provider-segment 2306 --provider-physical-network datacentre --project ibmscale ibmscale-tenant2
openstack subnet create \
          --network ibmscale-tenant2 \
          --subnet-range 10.8.64.0/18  \
          --ip-version 4 \
          --allocation-pool start=10.8.65.0,end=10.8.127.254 \
          --host-route destination=10.7.0.0/20,gateway=10.8.64.1 \
          --dhcp subnet-ibmscale-tenant2

openstack network create --provider-network-type vlan --provider-segment 2307 --provider-physical-network datacentre --project ibmscale ibmscale-tenant3
openstack subnet create \
          --network ibmscale-tenant3 \
          --subnet-range 10.8.128.0/18  \
          --ip-version 4 \
          --allocation-pool start=10.8.129.0,end=10.8.191.254 \
          --host-route destination=10.7.0.0/20,gateway=10.8.128.1 \
          --dhcp subnet-ibmscale-tenant3

openstack network create --provider-network-type vlan --provider-segment 2308 --provider-physical-network datacentre --project ibmscale ibmscale-tenant4
openstack subnet create \
          --network ibmscale-tenant4 \
          --subnet-range 10.8.192.0/18  \
          --ip-version 4 \
          --allocation-pool start=10.8.193.0,end=10.8.254.254 \
          --host-route destination=10.7.0.0/20,gateway=10.8.192.1 \
          --dhcp subnet-ibmscale-tenant4
