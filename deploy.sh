#!/bin/sh

openstack overcloud deploy --stack overcloud \
		--validation-errors-nonfatal \
		--templates /usr/share/openstack-tripleo-heat-templates \
		-n custom_network_data.yaml \
		--vip-file custom_vip_data.yaml \
		--baremetal-deployment overcloud_baremetal_deploy.yaml \
		-r roles_data.yaml \
		--deployed-server \
		-e containers-prepare-parameter.yaml \
		-e /usr/share/openstack-tripleo-heat-templates/environments/memcached-use-ips.yaml \
		-e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ml2-ansible.yaml \
		-e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml \
		-e enable-tls.yaml \
		-e tls-endpoints-public-dns.yaml \
		-e cloudname.yaml \
		-e esi-custom.yaml

