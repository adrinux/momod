#!/bin/sh

# For docker containers running behind traefik
cp /etc/letsencrypt/live/{{ fqdn }}/fullchain.pem /data/momod/certbot/cert.pem || exit 1
cp /etc/letsencrypt/live/{{ fqdn }}/privkey.pem /data/momod/certbot/key.pem || exit 1
# traefik automatically detects changes if watch is set
