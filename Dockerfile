FROM pihole/pihole:latest
LABEL maintainer="Patrick Thoelken <me@patrick-thoelken.de>"

COPY /src/VERSION /etc/docker-pi-hole-version
COPY /src/pi-hole.conf /home/pi-hole.conf
COPY /src/unbound /home/unbound
COPY /src/setupVars.conf /home/setupVars.conf
COPY /src/updateGrav /home/updateGrav

RUN mkdir -p /var/log/unbound/
RUN touch /var/log/unbound/unbound.log

RUN apt -y update && apt -y upgrade
RUN apt -y install git wget nano dos2unix unbound python3 python3-setuptools

RUN git clone https://github.com/anudeepND/whitelist.git /opt/whitelist
RUN chmod +x /opt/whitelist/scripts/whitelist.py

RUN echo "BLOCKINGMODE=NULL" >> /etc/pihole/pihole-FTL.conf
RUN echo "IGNORE_LOCALHOST=yes" >> /etc/pihole/pihole-FTL.conf
RUN echo "PRIVACYLEVEL=0" >> /etc/pihole/pihole-FTL.conf
RUN echo "AAAA_QUERY_ANALYSIS=no" >> /etc/pihole/pihole-FTL.conf

RUN /etc/init.d/unbound stop

RUN wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.root

RUN mv /home/pi-hole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
RUN mv /home/setupVars.conf /etc/pihole/setupVars.conf
RUN mv /home/unbound /etc/cron.monthly/unbound

RUN /etc/init.d/unbound restart

RUN dos2unix /etc/cron.monthly/unbound
RUN chmod +x /etc/cron.monthly/unbound

RUN pihole --regex "^wpad\."
RUN pihole -g
RUN pihole restartdns

RUN mkdir /opt/updateGrav
RUN mv /home/updateGrav /opt/updateGrav/updateGrav
RUN dos2unix /opt/updateGrav/updateGrav
RUN chmod +x /opt/updateGrav/updateGrav

RUN echo "0 */12 * * *     root    pihole -g" >> /etc/crontab
RUN echo "@reboot     root    pihole -g" >> /etc/crontab
RUN echo "0 4 * * *     root    pihole restartdns" >> /etc/crontab
RUN echo "0 1 * * */7     root    /opt/whitelist/scripts/whitelist.py" >> /etc/crontab
RUN echo "0 2 * * */7     root    /opt/updateGrav/updateGrav" >> /etc/crontab

RUN /etc/init.d/cron restart
RUN python3 /opt/whitelist/scripts/whitelist.py
RUN /opt/updateGrav/updateGrav https://v.firebog.net/hosts/lists.php?type=tick
RUN /opt/updateGrav/updateGrav 

RUN pihole -g

RUN apt -y --purge autoremove \
    && apt clean autoclean \
    && apt clean \
    && apt autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && rm -rf /tmp/*

ENV IPv6 True

EXPOSE 5353 5353/udp

ENV S6_LOGGING 0
ENV S6_KEEP_ENV 1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

ENV ServerIP 0.0.0.0
ENV FTL_CMD no-daemon
ENV DNSMASQ_USER pihole

ENV PATH /opt/pihole:${PATH}

HEALTHCHECK CMD dig +short +norecurse +retry=0 @127.0.0.1 pi.hole || exit 1

SHELL ["/bin/bash", "-c", "/etc/init.d/unbound start"]