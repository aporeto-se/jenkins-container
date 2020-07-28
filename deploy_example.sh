#!/bin/bash

FQDN="jenkins.se.aporeto.io"
EMAIL="jscott@paloaltonetworks.com"

nginx=/var/jenkins/nginx
sudo mkdir -p $nginx/certs
sudo mkdir -p $nginx/vhost.d
sudo mkdir -p $nginx/html

chown -Rf ubuntu:ubuntu $nginx

docker run --detach \
  --name nginx-proxy \
  --restart always \
  -p 80:80 \
  -p 443:443 \
  --volume /var/jenkins/nginx/certs:/etc/nginx/certs \
  --volume /var/jenkins/nginx/vhost.d:/etc/nginx/vhost.d \
  --volume /var/jenkins/nginx/html:/usr/share/nginx/html \
  --volume /var/run/docker.sock:/tmp/docker.sock:ro \
  jwilder/nginx-proxy

docker run --detach \
  --name nginx-proxy-letsencrypt \
  --restart always \
  --volumes-from nginx-proxy \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  --env "DEFAULT_EMAIL=$EMAIL" \
  jrcs/letsencrypt-nginx-proxy-companion

sudo mkdir -p /var/jenkins/jenkins
sudo chown -Rf ubuntu:ubuntu /var/jenkins/jenkins

docker run -d --name jenkins \
  -p 8080 \
  -p 50000:50000 \
  --env "VIRTUAL_HOST=$FQDN" \
  --env "LETSENCRYPT_HOST=$FQDN" \
  --env "VIRTUAL_PORT=8080" \
  --volume /var/jenkins/jenkins:/var/jenkins_home  \
  jodydadescott/prisma-jenkins:latest
