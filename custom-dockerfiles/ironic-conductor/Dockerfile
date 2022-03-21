FROM quay.io/tripleowallaby/openstack-ironic-conductor:current-tripleo

USER root
WORKDIR /tmp

RUN sed -i 's/$stream/8-stream/g' /etc/yum.repos.d/CentOS-* && \
        yum -y install git && \
        git config --global user.email "pilot@esi.moc" && \
        git config --global user.name "Pilot ESI" && \
        git clone https://review.opendev.org/openstack/ironic && \
        cd ironic && \
	git checkout stable/wallaby && \
        git fetch https://review.opendev.org/openstack/ironic refs/changes/56/804156/1 && git cherry-pick FETCH_HEAD && \
        git fetch https://review.opendev.org/openstack/ironic refs/changes/86/817086/1 && git cherry-pick FETCH_HEAD || true && \
        git add ironic/drivers/modules/ramdisk.py && git commit --no-edit && \
        git fetch https://review.opendev.org/openstack/ironic refs/changes/07/812007/4 && git cherry-pick FETCH_HEAD && \
        python3 setup.py install && \
    	yum clean all

WORKDIR /
USER ironic
        
