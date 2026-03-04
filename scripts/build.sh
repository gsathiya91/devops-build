#!/bin/bash

docker build -t $1 .
docker tag $1 $2
docker push $2