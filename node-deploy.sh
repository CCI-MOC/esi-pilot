openstack overcloud node provision \
  --stack overcloud \
  --network-config \
  --output overcloud-baremetal-deployed.yaml \
  --overcloud-ssh-key /home/stack/.ssh/id_rsa \
  overcloud_baremetal_deploy.yaml
