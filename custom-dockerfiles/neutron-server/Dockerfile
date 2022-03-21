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

WORKDIR /
USER neutron
