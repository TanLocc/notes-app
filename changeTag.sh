#!/bin/bash
cd deployk8s
sed "s/tagVersion/$1/g" app-deployment.yaml > note-app-deployment.yaml
rm -rf app-deployment.yaml
