FROM quay.io/tripleowallaby/openstack-neutron-server:current-tripleo

USER root
WORKDIR /tmp

RUN sed -i 's/$stream/8-stream/g' /etc/yum.repos.d/CentOS-* && \
        yum -y install --nogpgcheck git && \
	git clone https://github.com/CCI-MOC/network-runner && \
	cd network-runner && \
        git checkout esi_network_runner && \
	python3 setup.py install && \
	\mv /etc/ansible/roles/network-runner /etc/ansible/roles/network-runner.bak && \
	\cp -r etc/ansible/roles/network-runner /etc/ansible/roles/ && \
	yum clean all

RUN cd /tmp && \
        mkdir esi && \
        cd esi && \
        git clone https://github.com/CCI-MOC/networking-ansible && \
        cd networking-ansible && \
        git checkout esi_networking_ansible && \
        \cp /usr/lib/python3.6/site-packages/networking_ansible/ml2/mech_driver.py /usr/lib/python3.6/site-packages/networking_ansible/ml2/mech_driver.py.bak && \
        \cp networking_ansible/ml2/mech_driver.py /usr/lib/python3.6/site-packages/networking_ansible/ml2/mech_driver.py

RUN cd /etc/ansible && \
        \cp ansible.cfg ansible.cfg.bak && \
        sed -i 's/#command_timeout = 30/command_timeout = 300/g' ansible.cfg

WORKDIR /
USER neutron

RUN ansible-galaxy collection install dellemc.os9
RUN ansible-galaxy collection install community.network
