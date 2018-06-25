#!/usr/bin/env bash

docker rm $(docker ps -aq)
docker image rm $(docker image ls -aq)
docker volume rm $(docker volume ls -q)
docker network prune
