# ESI Scripts

## `dangling-ports.py`

`python dangling-ports.py <subnet>`

This script lists all neutron ports in a subnet associated with a baremetal port, in an attempt to identify
those that may no longer be in use. Its output is a series of commands which, if run, will delete those
ports. Ports associated with a lessee's node have these commands commented out, so they will not be automatically
run if the output commands are used.

This script is primarily intended to be used with the provisioning subnet, as various issues can cause dangling ports.

## `lease-email.py`

`python lease-email.py <email_config>`

This script sends lease reminder emails. The email configuration controls the behavior; for example this config will send out a reminder email to everyone:

```
{
    "smtp_server": "XXXXXXXXXXXXXXXXXXXXXXX",
    "smtp_port": XXX,
    "smtp_username": "XXXXXXXXXXXXXXXXXXXXXXXXX",
    "smtp_password": "XXXXXXXXXXXXXXXXXXXXXXXXX",
    "smtp_from": "esi@massopen.cloud",
    "subject_template": "[MOC ESI] Leased Nodes for Project {project}",
    "body_template": "You are receiving this reminder email because you have leased nodes in the MOC ESI. If you have any unused nodes, please cancel those leases.<br /><br />{lease_table}<br /><hr />You are receiving this email because you are a user of the MOC ESI cluster. If you would like to stop receiving email you will need to delete your account by contacting <a href='mailto:support@massopen.cloud'>support@massopen.cloud</a>"
}
```

While this one will send out an email to users whose leases are expiring within 5 days:

```
{
    "smtp_server": "XXXXXXXXXXXXXXXXXXXXXXX",
    "smtp_port": XXX,
    "smtp_username": "XXXXXXXXXXXXXXXXXXXXXXXXX",
    "smtp_password": "XXXXXXXXXXXXXXXXXXXXXXXXX",
    "smtp_from": "esi@massopen.cloud",
    "lease_filter": {
	"filter": "expiring",
	"within": 5
    },
    "subject_template": "[MOC ESI] Expiring Leases for Project {project}",
    "body_template": "You are receiving this reminder email because you have leased nodes in the MOC ESI that will expire soon. Please contact the MOC ESI administrators if you would like to extend these leases.<br /><br />{lease_table}<br /><hr />You are receiving this email because you are a user of the MOC ESI cluster. If you would like to stop receiving email you will need to delete your account by contacting <a href='mailto:support@massopen.cloud'>support@massopen.cloud</a>"
}
```

The presumption is that the administrator will set up a periodic job running this script.