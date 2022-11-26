#!/usr/bin/env bash
docker build .  -t ${DOCKER_IMAGE}:latest
docker tag ${DOCKER_IMAGE}:latest ${DOCKER_IMAGE}:${dockerTag}
docker push ${DOCKER_IMAGE}:${dockerTag}
docker push ${DOCKER_IMAGE}:latest