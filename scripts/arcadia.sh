#!/bin/bash
# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done
# install nginx
apt-get update
apt-get -y install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -y install \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose-plugin
docker network create internal
docker run -dit -h mainapp --restart=always --name=mainapp --net=internal -p 8080:80 registry.gitlab.com/arcadia-application/main-app/mainapp:latest
docker run -dit -h backend --restart=always --name=backend --net=internal -p 8081:80 registry.gitlab.com/arcadia-application/back-end/backend:latest
docker run -dit -h app2 --restart=always --name=app2 --net=internal -p 8082:80 registry.gitlab.com/arcadia-application/app2/app2:latest
docker run -dit -h app3 --restart=always --name=app3 --net=internal -p 8083:80 registry.gitlab.com/arcadia-application/app3/app3:latest