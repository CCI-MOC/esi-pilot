FROM quay.io/tripleowallaby/openstack-horizon:current-tripleo

USER root
WORKDIR /tmp

RUN sed -i 's/$stream/8-stream/g' /etc/yum.repos.d/CentOS-* && \
        sed -i 's/$contentdir/centos/g' /etc/yum.repos.d/CentOS-* && \
        sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo && \
        sed -i s/^#.*baseurl=http/baseurl=https/g /etc/yum.repos.d/*.repo && \
        sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo && \
        yum -y install --nogpgcheck git && \
        cd /tmp && \
        git clone https://github.com/CCI-MOC/esi-ui && \
        cd esi-ui && \
        git checkout tags/0.2 -b branch-0.1 && \
        python3 setup.py install && \
        cp /usr/local/lib/python3.6/site-packages/esi_ui/enabled/*.py /usr/share/openstack-dashboard/openstack_dashboard/local/enabled/. && \
        cd /tmp && \
        git clone https://github.com/CCI-MOC/esisdk && \
        cd esisdk && \
        git checkout tags/0.5 -b branch-0.5 && \
        python3 setup.py install && \
        cd /tmp && \
        git clone https://opendev.org/openstack/metalsmith && \
        cd metalsmith && \
        git checkout tags/2.3.0 -b branch-2.3.0 && \
        python3 setup.py install && \
        cd /tmp && \
        git clone https://opendev.org/openstack/openstacksdk && \
        cp /tmp/openstacksdk/openstack/warnings.py /usr/lib/python3.6/site-packages/openstack/. && \
        cd /usr/share/openstack-dashboard && \
        ./manage.py collectstatic --noinput && \
        ./manage.py compress && \
        yum clean all

WORKDIR /
USER root
