#!/bin/sh

if [[ $1 == "prepare" ]]; then
    # note: we shouldn't enroll oct4-07 in ironic since it's been used by cloudlab
    for n in 06 08 09 10 12 13 14 15 16 17
    do
        echo "manage oct4-$n"
        openstack baremetal node manage oct4-$n
        openstack baremetal node set --instance-info storage_interface=cinder oct4-$n
    done

elif [[ $1 == "inspect" ]]; then
    for n in 06 08 09 10 12 13 14 15 16 17
    do
        openstack baremetal node inspect oct4-$n
    done

elif [[ $1 == "provide" ]]; then
    for n in 06 08 09 10 12 13 14 15 16 17
    do
        openstack baremetal node provide oct4-$n
    done
