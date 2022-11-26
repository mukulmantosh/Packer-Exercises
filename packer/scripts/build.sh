#!/bin/bash
sudo yum install jq -y
sudo yum install -y git

sudo yum install -y docker
sudo usermod -a -G docker ec2-user
sudo systemctl enable docker.service
sudo systemctl start docker.service

sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx.service
sudo systemctl start nginx.service

IMAGE_TAG=`curl -L -s 'https://hub.docker.com/v2/repositories/mukulmantosh/packerexercise/tags'|jq '."results"[0]["name"]' | bc`

sudo docker pull mukulmantosh/packerexercise:$IMAGE_TAG
sudo docker run -d --name fastapi --restart always -p 8080:8080 mukulmantosh/packerexercise:$IMAGE_TAG