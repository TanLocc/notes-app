#!/bin/bash
sed "s/tagVersion/$1/g" app-deployment.yaml > note-app-deployment.yaml
