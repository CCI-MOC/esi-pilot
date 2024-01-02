FROM quay.io/tripleowallaby/openstack-ironic-conductor:current-tripleo

USER root
WORKDIR /tmp

ADD patches patches

RUN sed -i 's/$stream/8-stream/g' /etc/yum.repos.d/CentOS-* && \
        yum -y install --nogpgcheck git && \
        git config --global user.email "pilot@esi.moc" && \
        git config --global user.name "Pilot ESI" && \
        git clone https://review.opendev.org/openstack/ironic && \
        cd ironic && \
	git checkout stable/wallaby && \
        git apply /tmp/patches/0001-Enable-priority-overrides-to-enable-disable-steps.patch && \
        git apply /tmp/patches/0001-Create-node-get_interface-method.patch && \
        git apply /tmp/patches/0001-Fix-restricted-allocation-creation-for-old-policy-de.patch && \
        python3 setup.py install && \
    	yum clean all

WORKDIR /
USER ironic
