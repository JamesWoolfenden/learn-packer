FROM hashicorp/terraform:latest@sha256:c89ed543266c8756e04791fd68eaa45063c91f802a793c0df6cb522ee435ba2d

RUN apk update && \
    apk add --update \
    nodejs-current nodejs-npm \
    python python-dev py-pip build-base

RUN pip install --upgrade pip
RUN pip install awscli
