#!/bin/sh
apk update
apk add --update nodejs-current nodejs-npm
apk add --update python python-dev py-pip build-base
pip install --upgrade pip
pip install awscli
