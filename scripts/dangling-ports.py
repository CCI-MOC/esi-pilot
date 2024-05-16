#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import argparse

import openstack


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("subnet_name", type=str, help="name of subnet")
    args = parser.parse_args()

    subnet_name = args.subnet_name

    conn = openstack.connect()

    subnet = conn.network.find_subnet(subnet_name)
    network_uuid = subnet.network_id
    ports = list(conn.network.ports(network_id=network_uuid))
    baremetal_ports = list(conn.baremetal.ports(details=True))
    nodes = list(conn.baremetal.nodes(details=True))
    projects = list(conn.identity.projects())

    print("# %s total ports" % len(ports))
    for port in ports:
        # only check the ports associated with a baremetal port
        bp = next((bp for bp in baremetal_ports if port.mac_address == bp.address), None)
        if not bp:
            continue
        node = next((n for n in nodes if n['uuid'] == bp['node_uuid']), None)
        if not node:
            continue
        
        fixed_ip = None
        if len(port.fixed_ips) > 0:
            fixed_ip = port.fixed_ips[0]['ip_address']

        # identify lessee, if it exists
        project = None
        if node.lessee:
            project = next((p for p in projects if p.id == node.lessee), None)
        if project is None:
            print("openstack port delete %s # %s: %s %s" % (port.id, node.name, node.provision_state, fixed_ip))
        else:
            # comment out lessee port deleting commands, so generated script doesn't run them automatically
            print("# openstack port delete %s # %s (%s): %s %s" % (port.id, node.name, project.name, node.provision_state, fixed_ip))

if __name__ == "__main__":
    main()
