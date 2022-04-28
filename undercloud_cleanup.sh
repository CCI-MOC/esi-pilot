#!/bin/sh

sudo podman rm -af
sudo podman rmi -af
sudo rm -rf \
    /var/lib/tripleo-config \
    /var/lib/config-data \
    /var/lib/container-config-scripts \
    /var/lib/container-puppet \
    /var/lib/heat-config \
    /var/lib/image-service \
    /var/lib/mysql

sudo rm -rf /etc/systemd/system/tripleo*
sudo systemctl daemon-reload
