#!/bin/bash -e

strFTLLockFile=/etc/pihole/post-installation.ftl.config.lock
strVarsLockFile=/etc/pihole/post-installation.vars.config.lock
strPostInstallationLockFile=/etc/pihole/post-installation.routine.lock

strSetupVarsConfig=/etc/pihole/setupVars.conf
strFTLConfig=/etc/pihole/pihole-FTL.conf

function ConsoleLog() {
    echo "[:: piholeunbound pthoeken ::] ---> $1"
}

function insertFTLConfig() {
    if [ ! -f $strFTLLockFile ]; then

        echo "REPLY_ADDR4=0.0.0.0" > $strFTLConfig
        echo "BLOCKINGMODE=NULL" >> $strFTLConfig
        echo "IGNORE_LOCALHOST=yes" >> $strFTLConfig
        echo "PRIVACYLEVEL=0" >> $strFTLConfig
        echo "AAAA_QUERY_ANALYSIS=no" >> $strFTLConfig

        echo "DELETE THIS FILE ONLY IF YOU HAVE TO RESET YOUR FTL CONFIG! AFTER DELETE PLEASE RESTART THE CONTAINER!" > $strFTLLockFile
        ConsoleLog "FTL Configuration are updated now!"

    else
        ConsoleLog "FTL Configuration was already up to date!"
    fi
}

function insertVarsConfig() {
    if [ ! -f $strVarsLockFile ]; then

        echo "IPV6_ADDRESS=0:0:0:0:0:0" > $strSetupVarsConfig
        echo "LIGHTTPD_ENABLED=true" >> $strSetupVarsConfig
        echo "CACHE_SIZE=10000" >> $strSetupVarsConfig
        echo "INSTALL_WEB_SERVER=true" >> $strSetupVarsConfig
        echo "INSTALL_WEB_INTERFACE=true" >> $strSetupVarsConfig
        echo "IPV4_ADDRESS=0.0.0.0" >> $strSetupVarsConfig
        echo "PIHOLE_INTERFACE=eth0" >> $strSetupVarsConfig
        echo "QUERY_LOGGING=true" >> $strSetupVarsConfig
        echo "BLOCKING_ENABLED=true" >> $strSetupVarsConfig
        echo "DNSMASQ_LISTENING=local" >> $strSetupVarsConfig
        echo "PIHOLE_DNS_1=127.0.0.1#5335" >> $strSetupVarsConfig
        echo "DNS_FQDN_REQUIRED=true" >> $strSetupVarsConfig
        echo "DNS_BOGUS_PRIV=true" >> $strSetupVarsConfig
        echo "DNSSEC=true" >> $strSetupVarsConfig
        echo "REV_SERVER=false" >> $strSetupVarsConfig

        echo "DELETE THIS FILE ONLY IF YOU HAVE TO RESET YOUR VARS CONFIG! AFTER DELETE PLEASE RESTART THE CONTAINER!" > $strVarsLockFile
        ConsoleLog "Vars Configuration are updated now!"

    else
        ConsoleLog "Vars Configuration was already up to date!"
    fi
}

function postInstallationRoutine() {

    if [ ! -f $strPostInstallationLockFile ]; then

        # curl https://dbl.oisd.nl/basic/ | sed '/^#/d' | tail -n +2 >> /etc/pihole/adlists.list
        curl https://raw.githubusercontent.com/pthoelken/piholeunbound/main/src/adlists.tmp >> /etc/pihole/adlists.list
        curl https://v.firebog.net/hosts/lists.php?type=tick >> /etc/pihole/adlists.list

        /bin/bash /opt/pihole/updatecheck.sh
        /bin/bash /opt/pihole/update.sh
        /usr/bin/python3 /opt/whitelist/scripts/whitelist.py
        /bin/bash /opt/updateGrav/updateGrav
        /bin/bash /usr/local/bin/pihole restartdns

        echo "DELETE THIS FILE ONLY IF YOU HAVE TO RESET YOUR ROUTINE CONFIG! AFTER DELETE PLEASE RESTART THE CONTAINER!"> $strPostInstallationLockFile
        ConsoleLog "Post installation processes are done! You can use your PiHole now."

    else
        ConsoleLog "Post installation routine was already running!"
    fi
}

insertFTLConfig
insertVarsConfig
postInstallationRoutine

exit 0
