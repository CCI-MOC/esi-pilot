#!/bin/sh

openstack overcloud deploy --stack overcloud  --working-dir ~/overcloud-deploy/overcloud \
	  --templates ~/tripleo-heat-templates \
	  -e ~/ironic-overcloud.yaml \
	  -n ~/custom_network_data.yaml \
	  --baremetal-deployment ~/overcloud_baremetal_deploy.yaml \
	  -r ~/roles_data.yaml \
	  --deployed-server \
	  -e ~/containers-prepare-parameter.yaml \
	  -e /usr/share/openstack-tripleo-heat-templates/environments/memcached-use-ips.yaml \
	  -e ~/esi-custom.yaml \
