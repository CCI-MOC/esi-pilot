# Updating the SSL Certificates on Overcloud

### Generate certificates on the undercloud
1. Generate new SSL certificates and privite key on undercloud:
```
sudo certbot certonly --manual --preferred-challenges dns
```
certbot will ask you to place a TXT DNS record under _acme-challenge.esi.massopen.cloud. Please find more details [here](https://eff-certbot.readthedocs.io/en/stable/using.html#manual).

2. All generated keys and issued certificates can be found in ``/etc/letsencrypt/live/esi.massopen.cloud``
### Deploy certificates on the overcloud
1. On each controller node, backup the old certificate file ``/etc/pki/tls/private/overcloud_endpoint.pem``

2. Generate new overcloud_endpoint.pem:
```
cat fullchain.pem > overcloud_endpoint.pem
cat privkey.pem  >> overcloud_endpoint.pem
```
Note: fullchain.pem and privkey.pem are from undercloud /etc/letsencrypt/live/esi.massopen.cloud

3. Restart haproxy containers:
```
sudo podman restart $(podman ps --format="{{.Names}}" | grep -w -E 'haproxy(-bundle-.*-[0-9]+)?')
```

