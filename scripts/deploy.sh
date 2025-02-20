#!/usr/bin/env bash

if [ -z $DEPLOY_URL ]; then
    echo "ERROR: DEPLOY_URL environment variable must be defined."
    exit 1
fi

curl -X POST $DEPLOY_URL