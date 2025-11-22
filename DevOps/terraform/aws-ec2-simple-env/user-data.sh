#!/bin/bash
set -e

sudo yum update -y
sudo yum install -y git

echo "Installing Docker via amazon-linux-extras..."
sudo amazon-linux-extras install docker -y

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

#### ADD OTHER PRE-INSTALLATION HERE

