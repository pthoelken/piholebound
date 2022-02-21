# PiHoleUnbound - Your PiHole with some additional Features
* First initial release on DockerHub

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
    volumes:
      - './piholeunbound/pihole:/etc/pihole/'
      - './piholeunbound/dnsmasq.d/:/etc/dnsmasq.d/'
    cap_add:
      - NET_ADMIN
    restart: always
```

# Docker Hub Project Page
* https://hub.docker.com/repository/docker/pthoelken/piholeunbound