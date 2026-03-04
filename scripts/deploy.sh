#!/bin/bash

docker pull $1
docker stop devops-container || true
docker rm devops-container || true
docker run -d -p 3000:3000 --name devops-container $1