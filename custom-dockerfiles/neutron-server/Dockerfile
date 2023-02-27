FROM quay.io/tripleowallaby/openstack-neutron-server:current-tripleo

USER root
WORKDIR /tmp

RUN sed -i 's/$stream/8-stream/g' /etc/yum.repos.d/CentOS-* && \
        yum -y install git && \
	git clone https://github.com/ansible-network/network-runner && \
	cd network-runner && \
        git checkout 0.3.6 && \
	python3 setup.py install && \
	yum clean all

RUN cd /tmp && \
        mkdir naved && \
        cd naved && \
        git clone https://github.com/naved001/network-runner && \
        cd network-runner && \
        git checkout vdx-nos/improve-performance && \
        \cp -r etc/ansible/roles/network-runner/providers/nos /etc/ansible/roles/network-runner/providers/.

RUN cd /tmp && \
        mkdir tzumainn && \
        cd tzumainn && \
        git clone https://opendev.org/x/networking-ansible && \
        cd networking-ansible && \
        git pull https://review.opendev.org/x/networking-ansible refs/changes/38/872138/1 && \
        \cp /usr/lib/python3.6/site-packages/networking_ansible/ml2/mech_driver.py /usr/lib/python3.6/site-packages/networking_ansible/ml2/mech_driver.py.bak && \
        \cp networking_ansible/ml2/mech_driver.py /usr/lib/python3.6/site-packages/networking_ansible/ml2/mech_driver.py

RUN cd /etc/ansible && \
        \cp ansible.cfg ansible.cfg.bak && \
        sed -i 's/#command_timeout = 30/command_timeout = 300/g' ansible.cfg

WORKDIR /
USER neutron

RUN ansible-galaxy collection install dellemc.os9
RUN ansible-galaxy collection install community.network
