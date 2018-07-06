#!/usr/bin/env bash

docker-compose stop
docker rm $(docker-compose ps -q)
docker images rm $(docker-compose images -q)
docker volume rm $(docker volume ls -q)
docker network prune
