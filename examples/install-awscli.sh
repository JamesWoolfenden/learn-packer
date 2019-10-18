#!/bin/sh
apk update
apk add --update nodejs-current nodejs-npm terraform
apk add --update python python-dev py-pip build-base
pip install --upgrade pip
pip install awscli
