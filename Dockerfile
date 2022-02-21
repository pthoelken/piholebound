FROM pihole/pihole:latest
LABEL maintainer="Patrick Thoelken <me@patrick-thoelken.de>"

ENV S6_LOGGING 0
ENV S6_KEEP_ENV 1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2
ENV ServerIP 0.0.0.0
ENV FTL_CMD no-daemon
ENV DNSMASQ_USER pihole
ENV PATH /opt/pihole:${PATH}
ENV IPv6 True

RUN apt -y update && apt -y upgrade
RUN apt -y install git wget nano dos2unix unbound python3 python3-setuptools

RUN mkdir /opt/updateGrav
RUN mkdir -p /var/log/unbound/
RUN touch /var/log/unbound/unbound.log

COPY /src/VERSION /etc/docker-pi-hole-version
COPY /src/pi-hole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
COPY /src/unbound /etc/cron.monthly/unbound
COPY /src/updateGrav /opt/updateGrav/updateGrav
COPY /src/unbound_s6-init.sh unbound_s6-init.sh
COPY /src/after-setup.sh /after-setup.sh

RUN git clone https://github.com/anudeepND/whitelist.git /opt/whitelist
RUN wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.root

RUN chmod +x /after-setup.sh
RUN chmod +x /opt/updateGrav/updateGrav
RUN chmod +x /opt/whitelist/scripts/whitelist.py
RUN chmod +x /etc/cron.monthly/unbound

RUN dos2unix /opt/updateGrav/updateGrav
RUN dos2unix /etc/cron.monthly/unbound

RUN pihole --regex "^wpad\."
RUN pihole -g

RUN echo "0 */12 * * *  root    pihole -g" >> /etc/crontab
RUN echo "@reboot       root    pihole -g" >> /etc/crontab
RUN echo "0 4 * * *     root    pihole restartdns" >> /etc/crontab
RUN echo "0 1 * * */7   root    /opt/whitelist/scripts/whitelist.py" >> /etc/crontab
RUN echo "0 2 * * */7   root    /opt/updateGrav/updateGrav" >> /etc/crontab

RUN echo "edns-packet-max=1232" > /etc/dnsmasq.d/99-edns.conf
RUN echo "/bin/bash /after-setup.sh" >> /start.sh

RUN apt -y --purge autoremove \
    && apt clean autoclean \
    && apt clean \
    && apt autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && rm -rf /tmp/*

EXPOSE 53 53/udp

HEALTHCHECK CMD dig +short +norecurse +retry=0 @127.0.0.1 pi.hole || exit 1

RUN chmod +x unbound_s6-init.sh
ENTRYPOINT ./unbound_s6-init.sh

SHELL ["/bin/bash", "-c"]