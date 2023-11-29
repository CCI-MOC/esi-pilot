#!/bin/sh

openstack identity provider create --remote-id https://sso.massopen.cloud/auth/realms/moc moc
cat > rules.json <<EOF
[
  {
    "local": [
      {
        "user": {
          "name": "{0}",
          "email": "{1}"
        }
      }
    ],
    "remote": [
      {
        "type": "OIDC-preferred_username"
      },
      {
        "type": "OIDC-email"
      }
    ]
  }
]
EOF
openstack mapping create --rules rules.json moc-mapping
openstack federation protocol create openid --mapping moc-mapping --identity-provider moc
