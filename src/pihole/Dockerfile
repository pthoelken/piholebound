FROM pihole/pihole:v5.8.1

COPY install-ptl.sh /usr/local/bin/install-ptl.sh
COPY VERSION /etc/docker-pi-hole-version
COPY pi-hole.conf /home/pi-hole.conf
COPY unbound /home/unbound
COPY setupVars.conf /home/setupVars.conf
COPY adlists.tmp /home/adlists.tmp
COPY updateGrav /home/updateGrav

RUN bash -ex install-ptl.sh 2>&1