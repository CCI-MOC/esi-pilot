# Node Import and Verification

## Node Import

Run `openstack baremetal create <node manifest>`

## Node Verification

Install the Python requirements in `requirements.txt`

`python node-check.py --threads <max threads> --output-file <output_file> <node_file> <action>`

* `node_file` should be a JSON file with the following values:

```
{
    "nodes": ["node1", "node2", "node3"],
    "image": "provisioning-image-name",
    "network": "network-image-name"
}
```
* `action` should be one of the following:
   * `show` verifies that nodes exist.
   * `inspect` inspects nodes (if inspection passes, the script will still fail the node if `local_gb` is equal to 0)
   * `provision` provisions nodes
* `max_threads` defaults to 10
   * This value should be bounded by the availability of ports on the provisioning subnet; take care to ensure that ports are also available for ESI users.
   * Note that if a node has multiple baremetal ports, all of them will claim a port on the provisioning subnet during inspection or provisioning.
   * The maximum number of ports can be determined by running `openstack subnet show <provisioning_subnet> and looking at the `allocation_pools` value.
   * The number of ports current in use can be determined by running `openstack port list | grep <provisioning_subnet_uuid> | wc -l`
* `output_file` defaults to out.csv
