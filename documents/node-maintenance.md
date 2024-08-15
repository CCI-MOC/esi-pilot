# ESI Hardware Maintenance

This document will outline how anyone can perform hardware maintenance on this ESI cluster, and how to provision new hardware into the ESI cluster.

## Prerequisites

Every user that will be working on node issues need to fulfil these requirements.

1. Have an active account on the MOC esi cluster
    1. Create an MGHPCC RegApp account [here](https://regapp.mss.mghpcc.org/)
    1. Login to MOC ESI at least once with the same SSO email [here](https://esi.massopen.cloud/dashboard/auth/login/?next=/dashboard/)
        1. *Note you may get an error about not being assigned a project, this is okay*
    1. Notify ESI admins that you did this
1. Be a member of the `hwbroken` project on the MOC ESI cluster (An admin will do this)

## OpenStack CLI

During troubleshooting you'll need to interact with OpenStack often, which requires setting up your client to connect to the MOC ESI cluster.

1. Login through the [MOC ESI dashboard](https://esi.massopen.cloud/dashboard/auth/login/?next=/dashboard/) and create an application credential.
    1. Navigate to Identity > Application Credential > Create Application Credential to do that
1. Create the file `~/.config/openstack/clouds.yaml` and populate it with this content (Replace <> items)

    ```yaml
    cache:
        auth: true
    clouds:
        esi:
            auth:
                auth_url: https://esi.massopen.cloud:13000
                application_credential_id: "<PROJECT ID>"
                application_credential_secret: "<SECRET>"
            interface: "public"
            identity_api_version: 3
            auth_type: "v3applicationcredential"
    ```

1. You should now be able to run the command `openstack --os-cloud=esi esi node list` and you should see all the `hwbroken` nodes.

## IPMI Network Bastion VM

Often times access to the BMC interface of a node is required to troubleshoot. For this we have a VM acting as a bastion host which you can use `sshuttle` or similar tools to access any BMC on your local machine.

1. Provide your public key to ESI admins, they will add it to this VM
1. After that is done, connect using these details: `ssh techsquare@techsquare.massopen.cloud`
1. The BMC address of each node can be found using `openstack --os-cloud=esi baremetal node show <NODE LABEL> --fields=driver_info`, which will be accessible via the bastion VM.
    1. If you need to login to a chassis controller, if it exists, it will be the first IP in that block of 10. For example, the CMC address for the blade `10.2.14.112` would be `10.2.14.110`.

## What Happens when Server Breaks

If a server is having any sort of issue on ESI, the following steps will be taken by an ESI admin:

1. Remove any leases/offers on the node
1. Set the node owner to the `hwbroken` project
1. Lease the node to the `hwbroken` project indefinitely (makes it easy for admins to see if a node is broken at a glance)
1. Put the node in maintenance mode
1. Create a GitHub issue for tracking the maintenance of the issue

## Server Diagnosing/Fixing

The GitHub issue will have what the problem is, such as `fails provisioning`, or `fails cleaning`. Sometimes a more detailed error message might be in `openstack --os-cloud=esi baremetal node show <NODE LABEL>`. Otherwise, it will likely become necessary to login through the BMC and monitor the console while running the relevant OpenStack operation to see the issue.

For a node to be returned to service, it must have the following acceptance criteria:

1. Passed inspection with accurate introspection data.
    1. To run inspection on a node it must be managed: `openstack --os-cloud=esi baremetal node manage <NODE LABEL>`
    1. To run inspection use the command `openstack --os-cloud=esi baremetal node inspect <NODE LABEL>`
    1. The node state will either go back to `managed` if successful, or `inspect failed` if not
1. Passed cleaning
    1. To clean a node it must be managed
    1. To clean a node use the command `openstack --os-cloud=esi baremetal node provide <NODE LABEL>`
    1. The node will be `available` if successful (no longer managed), or `clean failed` if not
1. Passed deployment
    1. The node must be able to be deployed with an image.
    1. For this you can use metalsmith: `metalsmith --os-cloud=esi --resource-class <NODE RESOURCE CLASS> --image ubuntu-image --network hwbroken --candidate <NODE LABEL> --ssh-public-key <PATH TO LOCAL SSH PUBLIC KEY>`
    1. The node will be `active` if successful, or `deploy failed` if not
    1. To undeploy a node (either in failed or active state), use the command `metalsmith --os-cloud=esi undeploy <NODE LABEL>`

After all of this is successful, let ESI admins know and they will take the node out of the hwbroken project.

### Hardware Issues

If the issue is related to a hardware component, you can use any spare hardware from the spare hardware storage rack R4-PA-C22. If the issue is with an individual blade in a chassis you can replace without notice. If the chassis requires a hardware swap and not all the blades in the chassis are `hwbroken`, then that would need to be coordinated with ESI admins.

## Physical Hardware

### Node Labeling

Every node in ESI is labeled in the convention `<OWNER>-<CABINET><U>-<Slot>`. For example, `MOC-R4PAC10U29-S3` is the server that is in `R4-PA-C10` in `U29` and in slot `3` on the server. Servers that are standalone (not blades) omit the slot. ie. `MOC-R4PAC10U29`.

### Dell FX2 Chassis

A lot of MOC ESI hardware are Dell blades in Dell FX2 chassis. The user manual for this chassis can be found [here](https://dl.dell.com/topicspdf/fx_fx2_owners_manual_en-us.pdf). The FX2 can be configured in 8-node (Dell FC430 blades), 4-node (Dell FC630 blades), or 2-node (Dell FC830 blades) layouts. To determine what slot is which you can either flash in the iDrac, or see the user manual linked above on page 23. That document also has the layouts for which PCIe slots map to which blades, and which network interfaces match to which blade, should that be relevant.

#### Factory Resetting a CMC

If there is a need to factory reset the chassis management controller in a CMC, the process is somewhat convoluted unfortunately.

1. If you don't know the password or it doesn't work for some reason
    1. Remove the CMC and apply a jumper on the password reset pin, slot CMC back in
1. Serial into the CMC, login with `root`/`calvin`
1. `racadm racresetcfg` to factory reset the CFG
1. `racadm setniccfg -d` to enable dhcp on the CMC

## Discussion/Collaboration

You can reach all the ESI admins in the #ESI slack channel in the MOCA slack. We can set this channel up as a connection to existing slack workplaces on request.
