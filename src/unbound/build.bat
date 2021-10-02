cd /D "%~dp0" 
docker build -t pihole-ptl:latest .
docker image ls
docker tag 11ff pthoelken/pihole-ptl:latest
docker push pthoelken/pihole-ptl

docker ps --all
docker container ls
docker images ls
docker volume ls
docker rm *
docker 