FROM hashicorp/terraform

RUN apk update && \
    apk add --update \
    nodejs-current nodejs-npm \
    python python-dev py-pip build-base

RUN pip install --upgrade pip
RUN pip install awscli
