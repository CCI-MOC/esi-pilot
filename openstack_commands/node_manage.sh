#!/bin/sh

if [[ $1 == "prepare" ]]; then
    RAMDISK=$(openstack image show centos-8-deploy-ramdisk  -f value -c id)
    KERNEL=$(openstack image show centos-8-deploy-kernel -f value -c id)
    mac_06=00:0f:53:53:a8:40
    mac_08=00:0f:53:30:7c:30
    mac_09=00:0f:53:53:8e:00
    mac_10=00:0f:53:57:83:71
    mac_12=00:0f:53:2c:4a:41
    mac_13=00:0f:53:24:9e:50
    mac_14=00:0f:53:22:e0:70
    mac_15=00:0f:53:30:87:c0
    mac_16=00:0f:53:53:aa:20
    mac_17=00:0f:53:2c:4b:90

# note: we shouldn't enroll oct4-07 in ironic since it's been used by cloudlab
    for n in 06 08 09 10 12 13 14 15 16 17
    do
        openstack baremetal node manage oct4-$n
        echo "managed oct4-$n"
        openstack baremetal node set oct4-$n --driver-info deploy_kernel=$KERNEL --driver-info deploy_ramdisk=$RAMDISK --resource-class baremetal
        uuid=$(openstack baremetal node show oct4-$n -f value -c uuid)
        port=$((18-10#$n))
        mac=mac_$n
        openstack baremetal port create --node $uuid ${!mac}  --local-link-connection switch_info=switch1 --local-link-connection switch_id=4c:d9:8f:dc:e0:c9 --local-link-connection port_id=Te1/$port --physical-network datacentre
        openstack baremetal node set  --property capabilities=iscsi_boot:True oct4-$n
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
