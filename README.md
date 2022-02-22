# PiHoleUnbound - PiHole + Unbound
* First initial release on DockerHub

# Informations
Please be informed, that the container start needs to be 3-5 Minutes in case of updating all blacklist databases. When your web interface is up you can use your pihole. Otherwise you can inspect your container with docker logs <containername> to check the status of starting.

# Features
* Automatic Grav Update
* Automatic Unbound DNS Integration with fast and direct Root DNS Servers
* Automatic inserts of AdLists 

# docker-compose.yml
```version: "3.4"

services:
  piholeunbound:
    container_name: piholeunbound
    image: pthoelken/piholeunbound:latest
    ports:
      - "53:53/udp"
      - "67:67/udp"
      - "80:80/tcp"
    environment:
      TZ: 'Europe/Berlin'
      WEBPASSWORD: 'YOUR-STRONG-PASSWORD'
      VIRTUAL_HOST: "pi.hole"
      SERVERIP: "127.0.0.1"
      HOSTNAME: "piholeunbound"
    volumes:
      - './piholeunbound/pihole:/etc/pihole/'
      - './piholeunbound/dnsmasq.d/:/etc/dnsmasq.d/'
    dns: 
      - 1.1.1.1
      - 1.0.0.1
    cap_add:
      - NET_ADMIN
    restart: always
```

# Docker Hub Project Page
* https://hub.docker.com/repository/docker/pthoelken/piholeunbound