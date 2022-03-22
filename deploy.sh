#!/bin/sh

openstack overcloud deploy --stack overcloud \
	  --templates /usr/share/openstack-tripleo-heat-templates \
	  -n custom_network_data.yaml \
	  --baremetal-deployment overcloud_baremetal_deploy.yaml \
	  -r roles_data.yaml \
	  --deployed-server \
	  -e containers-prepare-parameter.yaml \
	  -e /usr/share/openstack-tripleo-heat-templates/environments/memcached-use-ips.yaml \
      -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ml2-ansible.yaml \
	  -e ml2-ansible-hosts.yaml \
	  -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml \
	  -e esi-custom.yaml
