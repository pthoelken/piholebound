#!/bin/bash -ex

### MAINTAIN UPDATE ###
apt -y update && apt -y upgrade
apt -y install git wget nano dos2unix unbound

### INSTALL WHITELIST TO PIHOLE ###
apt -y install python3 python3-setuptools
git clone https://github.com/anudeepND/whitelist.git /opt/whitelist
chmod +x /opt/whitelist/scripts/whitelist.py

/etc/init.d/cron restart

### CONFIG PIHOLE CONFIGURATION ###
echo "BLOCKINGMODE=NULL" >> /etc/pihole/pihole-FTL.conf
echo "IGNORE_LOCALHOST=yes" >> /etc/pihole/pihole-FTL.conf
echo "PRIVACYLEVEL=0" >> /etc/pihole/pihole-FTL.conf
echo "AAAA_QUERY_ANALYSIS=no" >> /etc/pihole/pihole-FTL.conf

### UNBOUND DNS SERVER INSTALL AND SET TO PIHOLE ###
/etc/init.d/unbound stop

wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.root

#-> Copy config and unbound files
mv /home/pi-hole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
mv /home/setupVars.conf /etc/pihole/setupVars.conf
mv /home/unbound /etc/cron.monthly/unbound

/etc/init.d/unbound restart

#-> Setup cronjobs for unbound
dos2unix /etc/cron.monthly/unbound
chmod +x /etc/cron.monthly/unbound

/etc/init.d/cron restart

### CONFIG PIHOLE GRAV ###
pihole --regex "^wpad\."
pihole -g
pihole restartdns

### SETUP AUTO UPDATE GRAV ###
mkdir /opt/updateGrav
mv /home/updateGrav /opt/updateGrav/updateGrav
dos2unix /opt/updateGrav/updateGrav
chmod +x /opt/updateGrav/updateGrav

### SETUP CRONTABS ###

echo "0 */12 * * *     root    pihole -g" >> /etc/crontab
echo "@reboot     root    pihole -g" >> /etc/crontab
echo "0 4 * * *     root    pihole restartdns" >> /etc/crontab
echo "0 1 * * */7     root    /opt/whitelist/scripts/whitelist.py" >> /etc/crontab
echo "0 2 * * */7     root    /opt/updateGrav/updateGrav" >> /etc/crontab

/etc/init.d/cron restart

python3 /opt/whitelist/scripts/whitelist.py
/opt/updateGrav/updateGrav

### UPDATE ADLIST ###
while read p; do
  sqlite3 /etc/pihole/gravity.db "INSERT INTO "adlist" ("address","enabled","comment") VALUES ('$p','1','Insert by Setup');"
done </home/adlists.tmp

pihole -g
