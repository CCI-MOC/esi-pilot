# Post-Deployment Ansible Playbooks

## After Overcloud Node Provisioning

```
ansible-playbook -i inventory.yaml node_deploy/tasks/main.yaml
```

## After Overcloud Deployment

The `dnsmasq` playbook uses a custom EFI image. Run the following if you need to re-generate it:

```
git clone https://github.com/ipxe/ipxe.git
cd ipxe/src
# create custom ipxe file at custom.ipxe; current one in dnsmasq/tasks/custom.ipxe
make bin-x86_64-efi/snponly.efi EMBED=custom.ipxe
```

Available playbooks:

```
ansible-playbook -i inventory.yaml network-interfaces/tasks/main.yaml
ansible-playbook -i inventory.yaml switch/tasks/main.yaml --extra-vars ansible_switch_ssh_password=<> --extra-vars ansible_brocade_ssh_password=<> --extra-vars ansible_cisco_23_40_password=<>
ansible-playbook -i inventory.yaml dnsmasq/tasks/main.yaml
ansible-playbook -i inventory.yaml policy/tasks/main.yaml
ansible-playbook -i inventory.yaml neutron_config/tasks/main.yaml
ansible-playbook -i inventory.yaml ironic_config/tasks/main.yaml
ansible-playbook -i inventory.yaml volume/tasks/main.yaml --extra-vars rbd_iscsi_api_password="xxx" --extra-vars rbd_secret_uuid="xxx"
re-new ssl certificate:
ansible-playbook -i inventory.yaml ssl_certificate_renew/tasks/main.yaml --extra-vars AWS_ACCESS_KEY_ID="xxx" --extra-vars AWS_SECRET_ACCESS_KEY="xxx"
re-open 7777 port for esi-leap service:
ansible-playbook -i inventory.yaml esi_leap/tasks/main.yaml
```