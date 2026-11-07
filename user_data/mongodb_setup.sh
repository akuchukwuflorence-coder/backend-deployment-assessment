#!/bin/bash
set -euxo pipefail

yum update -y
amazon-linux-extras install docker -y

systemctl enable --now docker
usermod -aG docker ec2-user

mkdir -p /opt/mongodb/data

docker run -d \
  --name mongodb \
  --restart unless-stopped \
  -p 27017:27017 \
  -v /opt/mongodb/data:/data/db \
  mongo:7