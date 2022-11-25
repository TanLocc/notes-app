#!/bin/bash
cd deployk8s
sed "s/tagVersion/$1/g" app-deployment.yaml > app-deployment.yaml
