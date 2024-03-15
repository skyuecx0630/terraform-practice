#!/bin/bash

yum install -y docker

systemctl enable --now docker

docker run -d -p 8080:8080 --restart always --name app hmoon630/sample-fastapi
