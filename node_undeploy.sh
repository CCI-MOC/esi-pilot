#!/bin/sh

openstack baremetal node undeploy oct4-01
openstack baremetal node undeploy oct4-03
openstack baremetal node undeploy oct4-04
openstack port delete overcloud-controller-0-ctlplane
openstack port delete overcloud-controller-1-ctlplane
openstack port delete overcloud-controller-2-ctlplane
