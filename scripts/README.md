# ESI Scripts

## `dangling-ports.py`

`python dangling-ports.py <subnet>`

This script lists all neutron ports in a subnet associated with a baremetal port, in an attempt to identify
those that may no longer be in use. Its output is a series of commands which, if run, will delete those
ports. Ports associated with a lessee's node have these commands commented out, so they will not be automatically
run if the output commands are used.

This script is primarily intended to be used with the provisioning subnet, as various issues can cause dangling ports.

