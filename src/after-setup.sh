#!/bin/bash

cat <<EOF > /etc/pihole/pihole-FTL.conf
REPLY_ADDR4=0.0.0.0
BLOCKINGMODE=NULL
IGNORE_LOCALHOST=yes
PRIVACYLEVEL=0
AAAA_QUERY_ANALYSIS=no
EOF

cat <<EOF > /etc/pihole/setupVars.conf
IPV6_ADDRESS=0:0:0:0:0:0
LIGHTTPD_ENABLED=true
CACHE_SIZE=10000
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
IPV4_ADDRESS=0.0.0.0
PIHOLE_INTERFACE=eth0
QUERY_LOGGING=true
BLOCKING_ENABLED=true
DNSMASQ_LISTENING=local
PIHOLE_DNS_1=127.0.0.1#5335
DNS_FQDN_REQUIRED=true
DNS_BOGUS_PRIV=true
DNSSEC=true
REV_SERVER=false
EOF

/usr/bin/python3 /opt/whitelist/scripts/whitelist.py
/bin/bash /opt/updateGrav/updateGrav
/bin/bash /usr/local/bin/pihole restartdns
