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
import concurrent.futures
import json
import subprocess

import openstack


def show_node(conn, node):
    print("%s: STARTING SHOW" % node)

    node_obj = None
    node_dict = {"node": node}
    message = None
    try:
        node_obj = conn.baremetal.get_node(node)
        message = node_obj.provision_state
        status = "success"
    except Exception as e:
        status = "fail"
        message = e

    node_dict['status'] = status
    node_dict['message'] = message
    
    print("%s: SHOW DONE" % node)
    return node_dict


def inspect_node(conn, node):
    print("%s: STARTING INSPECTION" % node)

    node_obj = None
    node_dict = {"node": node}
    message = None
    try:
        # make sure node exists
        node_obj = conn.baremetal.get_node(node)

        # inspect node
        print("%s: inspecting" % node)
        conn.baremetal.set_node_provision_state(node, 'inspect')

        # wait for node to be at manage state; or fail
        conn.baremetal.wait_for_nodes_provision_state(
            [node], 'manageable'
        )

        # check that local_gb > 0
        node_obj = conn.baremetal.get_node(node) 
        message = node_obj.properties
        if int(node_obj.properties.get('local_gb', 0)) > 0:
            status = "success"
        else:
            raise Exception('local_gb is 0')
    except Exception as e:
        status = "fail"
        message = e

    node_dict['status'] = status
    node_dict['message'] = message
    
    print("%s: INSPECTION DONE" % node)
    return node_dict


def provision_node(conn, node, image, network):
    print("%s: STARTING DEPLOY" % node)

    node_obj = None
    node_dict = {"node": node}
    message = None
    try:
        # make sure node exists
        node_obj = conn.baremetal.get_node(node)

        # if node is not 'available', put it into 'available'
        if node_obj.provision_state != 'available':
            print("%s: cleaning" % node)
            if node_obj.provision_state != 'manageable':
                conn.baremetal.set_node_provision_state(node, 'manage')
                conn.baremetal.wait_for_nodes_provision_state(
                    [node], 'manageable'
                )
            conn.baremetal.set_node_provision_state(node, 'provide')
            conn.baremetal.wait_for_nodes_provision_state(
                [node], 'available'
            )

        # provision node
        print("%s: deploying" % node)
        subprocess.run(['metalsmith', 'deploy',
                        '--image', image,
                        '--resource-class', node_obj.resource_class,
                        '--candidate', node,
                        '--network', network])

        # wait for node to be active; or fail
        conn.baremetal.wait_for_nodes_provision_state(
            [node], 'active'
        )

        # undeploy node
        print("%s: undeploying" % node)
        subprocess.run(['metalsmith', 'undeploy', node])
        conn.baremetal.wait_for_nodes_provision_state(
            [node], 'available'
        )
        status = "success"
    except Exception as e:
        status = "fail"
        message = e

    node_dict['status'] = status
    node_dict['message'] = message
    
    print("%s: DEPLOY DONE" % node)
    return node_dict


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("node_file", type=str, help="json file of nodes")
    parser.add_argument("action", type=str, help="inspect/provision/show")
    parser.add_argument('--threads', nargs='?', default=10, type=int)
    parser.add_argument('--output-file', nargs='?', default='out.csv')
    args = parser.parse_args()

    with open(args.node_file) as f:
        node_json = json.load(f)
        nodes = node_json.get("nodes", [])
        image = node_json.get("image", "")
        network = node_json.get("network", "")

    conn = openstack.connect()
    futures = []
    output_file = open(args.output_file, 'w')
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.threads) as executor:
        for node in nodes:
            if args.action == "inspect":
                futures.append(executor.submit(inspect_node, conn, node))
            elif args.action == "provision":
                futures.append(executor.submit(
                    provision_node, conn, node, image, network))
            elif args.action == "show":
                futures.append(executor.submit(show_node, conn, node))

        for future in concurrent.futures.as_completed(futures):
            result_dict = future.result()
            output_file.write("%s, %s, %s\n" % (
                result_dict['node'],
                result_dict['status'],
                result_dict['message']))

    output_file.close()
    print("OUTPUT: %s" % args.output_file)

if __name__ == "__main__":
    main()
