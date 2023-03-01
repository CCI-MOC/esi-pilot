# Running a Minor Update

A minor update allows an ESI admin to push configuration changes and update containers. Done properly,
there should be little to no downtime for an HA ESI installation.

## Update the overcloud Heat stack and container images

```
./update.sh
openstack overcloud external-update run --tags container_image_prepare
```

## Update each controller

It is recommended that each controller be updated individually to maintain uptime. This example
demonstrates the procedure for `controller-0`.

First, update the `CentOS-Stream-AppStream.repo` on the controller with the following:

```
exclude=container-selinux-2:2.189* pacemaker* corosync*
```

This change can be reverted post-update.

You may also want to backup the service configurations in `/var/lib/config-data/puppet-generated/` as a reference.

Next, run the update.

```
openstack overcloud update run --limit overcloud-controller-0
```

If this operation is interrupted, you must restart the Pacemaker cluster on the controller (`pcs cluster start`) before
re-running the update.

After the overcloud update completes for a controller, run specific post-deploy ansible playbooks for
the controller:

```
 ansible-playbook -i inventory.yaml switch/tasks/main.yaml --limit controller0 --extra-vars ansible_switch_ssh_password=<> --extra-vars ansible_brocade_ssh_password=<> --extra-vars ansible_cisco_23_40_password=<>
 ansible-playbook -i inventory.yaml dnsmasq/tasks/main.yaml --limit controller0
 ansible-playbook -i inventory.yaml policy/tasks/main.yaml --limit controller0
 ansible-playbook -i inventory.yaml ironic_config/tasks/main.yaml --limit controller0 
 ansible-playbook -i inventory.yaml ssl_certificate_renew/tasks/overcloud.yaml --limit controller0
```

If the controller hosts the Cinder volume service, run the volume playbook as well:

```
ansible-playbook -i inventory.yaml volume/tasks/main.yaml --extra-vars rbd_iscsi_api_password=<> --extra-vars rbd_secret_uuid=<> --limit controller0
```

There are additional steps to run afterwards:

* `cinder.conf` should be updated on the controllers that do *not* host the Cinder volume service.
* The controller running `esi-leap` should open port 7777.

Once the inital controller is updated, the other controllers can be updated in turn.

## Post-Controller Update

After all the updates are run, `ml2_conf.ini` may need to be updated on each controller so that the `coordination_url` points at the controller hosting the master redis bundle. This can be done by editing `inventory.yaml` by updating the `master_ip` to the internal IP address of this controller. Then run:

```
 ansible-playbook -i inventory.yaml switch/tasks/main.yaml --extra-vars ansible_switch_ssh_password=<> --extra-vars ansible_brocade_ssh_password=<> --extra-vars ansible_cisco_23_40_password=<>
```
