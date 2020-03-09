# Packer-Docker HCL2

Using Packer to build Docker might seem a bit strange at first. Aren't Dockerfiles a standard for building Docker containers?
I'd be thinking this'll never fly with my JS developers? But It can make sense.

To build with a Dockerfile, and to save to it to a registry requires 2 steps, first to build with a CI tool like Gitlab/Circle and requires a Dockerfile and a process to manage logging into the registry and pushing to it.

In Packer this entire process can be captured in one file, encapsulating all that's required, and as a bonus the whole process is runnable locally. Which make for quick debug cycle times.

Using Packer also allows the use and re-use of scripts and to use Ansible role and playbooks as used in other platform builds.

These HCL2 based examples target folders not individual files.

## A very basic Packer Docker template

Starting really simple with **examples-hcl/packer-docker-ubuntu**, this contains a source **docker.base1604.pkr.hcl** 

``` HCL
source "docker" "base1604" {
      image= "ubuntu"
      export_path= "export_image.tar"
}

```

and build file **build.base1604.pkr.hcl**

```HCL
build {
sources=[
  "source.docker.base1604"
  ]

}
```

Building this template with..

```cli
$  packer build .\packer-docker-ubuntu\
docker: output will be in this color.

==> docker: Creating a temporary directory for sharing data...
==> docker: Pulling Docker image: ubuntu
    docker: Using default tag: latest
    docker: latest: Pulling from library/ubuntu
    docker: Digest: sha256:04d48df82c938587820d7b6006f5071dbbffceb7ca01d2814f81857c631d44df
    docker: Status: Image is up to date for ubuntu:latest
    docker: docker.io/library/ubuntu:latest
==> docker: Starting docker container...
    docker: Run command: docker run -v C:\Users\james.woolfenden\packer.d\tmp766628703:/packer-files -d -i -t --entrypoint=/bin/sh -- ubuntu
    docker: Container ID: dd47b23d66f207284f54d6cd9803aa8a219842909d14b4fe037336539df36cde
==> docker: Using docker communicator to connect: 172.17.0.2
==> docker: Exporting the container
==> docker: Killing the container: dd47b23d66f207284f54d6cd9803aa8a219842909d14b4fe037336539df36cde
Build 'docker' finished.

==> Builds finished. The artifacts of successful builds are:
--> docker: Exported Docker file: export_image.tar
```

OK so that's Not that useful yet. Yet.

## Tagging with a post-processor

So far you have seen demonstrated that a build of a container with Packer, but it's not good for much yet.
Next is to start plugging in other components.

First up is a post-processor, used to tag the container.
Add this section to **build.base1604.pkr.hcl** after the sources.

```HCL
post-processor "docker-tag" {
      tag= "my-tag"
}
```

and change **docker.base1604.pkr.hcl** to:

```HCL
source "docker" "base1604" {
      image= "ubuntu"
      commit= true
}

```

Still not exactly Rocket Science yet, is it.

Trying it out.

```cli
$ packer build -var tag=2 packer-docker-tag-empty.json
docker output will be in this color.

==> docker: Creating a temporary directory for sharing data...
==> docker: Pulling Docker image: ubuntu
    docker: Using default tag: latest
    docker: latest: Pulling from library/ubuntu
    docker: Digest: sha256:017eef0b616011647b269b5c65826e2e2ebddbe5d1f8c1e56b3599fb14fabec8
    docker: Status: Image is up to date for ubuntu:latest
==> docker: Starting docker container...
    docker: Run command: docker run -v /home/jim/.packer.d/tmp:/packer-files -d -i -t ubuntu /bin/bash
    docker: Container ID: fe20e550df8e38e99a4a87ffe1836c646eecce7cf31db5da67f55d80c6ba54f8
==> docker: Using docker communicator to connect: 172.17.0.2
==> docker: Committing the container
    docker: Image ID: sha256:bd89cee10dc09fd28dd5cf1d00fc62fd659db014ef96b2d62a74eccf88c4b70d
==> docker: Killing the container: fe20e550df8e38e99a4a87ffe1836c646eecce7cf31db5da67f55d80c6ba54f8
==> docker: Running post-processor: docker-tag
    docker (docker-tag): Tagging image: sha256:bd89cee10dc09fd28dd5cf1d00fc62fd659db014ef96b2d62a74eccf88c4b70d
    docker (docker-tag): Repository: dave:2
Build 'docker' finished.

==> Builds finished. The artifacts of successful builds are:
--> docker: Imported Docker image: sha256:bd89cee10dc09fd28dd5cf1d00fc62fd659db014ef96b2d62a74eccf88c4b70d
--> docker: Imported Docker image: dave:2
```

So now we have a tagged Dave:2 container. Contain your excitement. Ok let's move on.

## Building into an AWS registry

This next example will do everything, ok the main stuff for a container, build, tag and push to ECR.
Running packer build **.\packer-docker-aws-ecr.json**

```json
{
  "_comment": "Docker AWS ECR",
  "variables": {
    "tag": "{{env `BUILD_NUMBER`}}",
    "repository": "123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container",
    "aws_access_key": "{{env `AWS_ACCESS_KEY_ID`}}",
    "aws_secret_key": "{{env `AWS_SECRET_ACCESS_KEY`}}",
    "login_server": "https://123456789012.dkr.ecr.eu-west-1.amazonaws.com/"
  },
  "_comment": "SSH needs to be on container for shell provisioner",
  "builders": [
    {
      "type": "docker",
      "image": "hashicorp/terraform",
      "commit": true
    }
  ],
  "post-processors": [
    [
      {
        "type": "docker-tag",
        "tag": "{{user `tag`}}",
        "repository": "{{user `repository`}}"
      },
      {
        "type": "docker-push",
        "ecr_login": true,
        "aws_access_key": "{{user `aws_access_key`}}",
        "aws_secret_key": "{{user `aws_secret_key`}}",
        "login_server": "{{user `login_server`}}"
      }
    ]
  ]
}
```

When this runs in Packer...

```cli
docker output will be in this color.

==> docker: Creating a temporary directory for sharing data...
==> docker: Pulling Docker image: hashicorp/terraform
    docker: Using default tag: latest
    docker: latest: Pulling from hashicorp/terraform
    docker: Digest: sha256:330bef7401e02e757e6fa2de69f398fd29fcbfafe2a3b9e8f150486fbcd7915b
    docker: Status: Image is up to date for hashicorp/terraform:latest
==> docker: Starting docker container...
    docker: Run command: docker run -v /c/Users/james.woolfenden/packer.d/tmp:/packer-files -d -i -t hashicorp/terraform /bin/bash
    docker: Container ID: fa8f17d078f1978cda0a7b0c9352e7afffc8a2cb57db425faff3cc8f9816cf5d
==> docker: Using docker communicator to connect:
==> docker: Committing the container
    docker: Image ID: sha256:759f4b14fe9d477a7a6492ff9c1becd77e3d8b1e01a89f07275c8d72f3e7907d
==> docker: Killing the container: fa8f17d078f1978cda0a7b0c9352e7afffc8a2cb57db425faff3cc8f9816cf5d
==> docker: Running post-processor: docker-tag
    docker (docker-tag): Tagging image: sha256:759f4b14fe9d477a7a6492ff9c1becd77e3d8b1e01a89f07275c8d72f3e7907d
    docker (docker-tag): Repository: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container:5
==> docker: Running post-processor: docker-push
    docker (docker-push): Fetching ECR credentials...
    docker (docker-push): Logging in...
    docker (docker-push): Login Succeeded
    docker (docker-push): Pushing: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container:5
    docker (docker-push): The push refers to repository [123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container]
    docker (docker-push): 6ad0db50b392: Preparing
    docker (docker-push): 1eeb4487de94: Preparing
    docker (docker-push): 9094b98cdb25: Preparing
    docker (docker-push): 503e53e365f3: Preparing
    docker (docker-push): 9094b98cdb25: Layer already exists
    docker (docker-push): 1eeb4487de94: Layer already exists
    docker (docker-push): 503e53e365f3: Layer already exists
    docker (docker-push): 6ad0db50b392: Pushed
    docker (docker-push): 5: digest: sha256:82de02fbaab0a2c35d033cae5278c59e1d8e65ee2bb4cb5a57b803536b305a3c size: 1155
    docker (docker-push): Logging out...
    docker (docker-push): Removing login credentials for 123456789012.dkr.ecr.eu-west-1.amazonaws.com
Build 'docker' finished.

==> Builds finished. The artifacts of successful builds are:
--> docker: Imported Docker image: sha256:759f4b14fe9d477a7a6492ff9c1becd77e3d8b1e01a89f07275c8d72f3e7907d
--> docker: Imported Docker image: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container:5
--> docker: Imported Docker image: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container:5
```

While that's great, we added nothing to the container so it doesn't prove that much yet.
Sure it connected to ECR and pushed the container, but we added nothing to it, for that, we need to add some Provisioners.

Packer builds containers will only work with Docker images that already have SSH on them. Reading this will save you a lot of time.
I've changed the base image from **hashicorp/terraform** to **ebiwd/alpine-ssh**, and added terraform to its package list.

This the shell script it runs on the Provisioner **install_awscli.sh**.

```bash
#!/bin/sh
apk update
apk add --update nodejs-current nodejs-npm terraform
apk add --update python python-dev py-pip build-base
pip install --upgrade pip
pip install awscli
```

## Provisioners

This next example combines the lot, it's imaginatively called **packer-docker-aws-ecr-shell.json**

```json
{
  "_comment": "Docker AWS ECR",
  "variables": {
    "tag": "{{env `BUILD_NUMBER`}}",
    "repository": "123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container",
    "aws_access_key": "{{env `AWS_ACCESS_KEY_ID`}}",
    "aws_secret_key": "{{env `AWS_SECRET_ACCESS_KEY`}}",
    "login_server": "https://123456789012.dkr.ecr.eu-west-1.amazonaws.com/"
  },
  "_comment": "SSH needs to be on container for shell provisioner",
  "builders": [
    {
      "type": "docker",
      "image": "ebiwd/alpine-ssh",
      "commit": true
    }
  ],
  "_comment": "probs bash needs to be there",
  "provisioners": [
    {
      "type": "shell",
      "inline": ["apk add bash"]
    },
    {
      "type": "shell",
      "script": "install-awscli.sh"
    }
  ],
  "post-processors": [
    [
      {
        "type": "docker-tag",
        "tag": "{{user `tag`}}",
        "repository": "{{user `repository`}}"
      },
      {
        "type": "docker-push",
        "ecr_login": true,
        "aws_access_key": "{{user `aws_access_key`}}",
        "aws_secret_key": "{{user `aws_secret_key`}}",
        "login_server": "{{user `login_server`}}"
      }
    ]
  ]
}
```

Let's built it:

```shell
$ packer build .\packer-docker-aws-ecr.json
docker output will be in this color.

==> docker: Creating a temporary directory for sharing data...
==> docker: Pulling Docker image: ebiwd/alpine-ssh
    docker: Using default tag: latest
    docker: latest: Pulling from ebiwd/alpine-ssh
    docker: 59265c40e257: Pulling fs layer
    docker: a621cd180b0b: Pulling fs layer
    docker: 1388eaedce13: Pulling fs layer
    docker: 75cc2d2e3f13: Pulling fs layer
    docker: b4ac607039c6: Pulling fs layer
    docker: 75cc2d2e3f13: Waiting
    docker: b4ac607039c6: Waiting
    docker: 59265c40e257: Verifying Checksum
    docker: 59265c40e257: Download complete
    docker: 59265c40e257: Pull complete
    docker: 75cc2d2e3f13: Verifying Checksum
    docker: 75cc2d2e3f13: Download complete
    docker: b4ac607039c6: Download complete
    docker: a621cd180b0b: Verifying Checksum
    docker: a621cd180b0b: Download complete
    docker: a621cd180b0b: Pull complete
    docker: 1388eaedce13: Verifying Checksum
    docker: 1388eaedce13: Download complete
    docker: 1388eaedce13: Pull complete
    docker: 75cc2d2e3f13: Pull complete
    docker: b4ac607039c6: Pull complete
    docker: Digest: sha256:6d994480f495fc7ddc16d126e4c41f9fc0153363b6f9e686f50d47039078615c
    docker: Status: Downloaded newer image for ebiwd/alpine-ssh:latest
==> docker: Starting docker container...
    docker: Run command: docker run -v /c/Users/SOMEUSER/packer.d/tmp:/packer-files -d -i -t ebiwd/alpine-ssh /bin/bash
    docker: Container ID: 5fbda610d9117b5a2c20f5da6e77b4cb230114c44fbf79b168a30e32e3bc26f2
==> docker: Using docker communicator to connect: 172.17.0.2
==> docker: Provisioning with shell script: C:\Users\SOMEUSER\AppData\Local\Temp\packer-shell350255759
    docker: OK: 68 MiB in 39 packages
    docker: WARNING: Ignoring APKINDEX.84815163.tar.gz: No such file or directory
    docker: WARNING: Ignoring APKINDEX.24d64ab1.tar.gz: No such file or directory
==> docker: Provisioning with shell script: install-awscli.sh
    docker: fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/main/x86_64/APKINDEX.tar.gz
    docker: fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/community/x86_64/APKINDEX.tar.gz
    docker: v3.6.5-5-geec223036a [http://dl-cdn.alpinelinux.org/alpine/v3.6/main]
    docker: v3.6.5-4-g1bf6e4dfc6 [http://dl-cdn.alpinelinux.org/alpine/v3.6/community]
    docker: OK: 8449 distinct packages available
    docker: fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/main/x86_64/APKINDEX.tar.gz
    docker: fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/community/x86_64/APKINDEX.tar.gz
    docker: (1/8) Installing libcrypto1.0 (1.0.2r-r0)
    docker: (2/8) Installing libgcc (6.3.0-r4)
    docker: (3/8) Installing http-parser (2.7.1-r1)
    docker: (4/8) Installing libssl1.0 (1.0.2r-r0)
    docker: (5/8) Installing libstdc++ (6.3.0-r4)
    docker: (6/8) Installing libuv (1.11.0-r1)
    docker: (7/8) Installing nodejs-current (7.10.1-r1)
    docker: (8/8) Installing nodejs-npm (6.10.3-r2)
    docker: Executing busybox-1.26.2-r11.trigger
    docker: OK: 110 MiB in 47 packages
    docker: fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/main/x86_64/APKINDEX.tar.gz
    docker: fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/community/x86_64/APKINDEX.tar.gz
    docker: (1/19) Upgrading musl (1.1.16-r14 -> 1.1.16-r15)
    docker: (2/19) Installing binutils-libs (2.30-r1)
    docker: (3/19) Installing binutils (2.30-r1)
    docker: (4/19) Installing gmp (6.1.2-r0)
    docker: (5/19) Installing isl (0.17.1-r0)
    docker: (6/19) Installing libgomp (6.3.0-r4)
    docker: (7/19) Installing libatomic (6.3.0-r4)
    docker: (8/19) Installing pkgconf (1.3.7-r0)
    docker: (9/19) Installing mpfr3 (3.1.5-r0)
    docker: (10/19) Installing mpc1 (1.0.3-r0)
    docker: (11/19) Installing gcc (6.3.0-r4)
    docker: (12/19) Installing musl-dev (1.1.16-r15)
    docker: (13/19) Installing libc-dev (0.7.1-r0)
    docker: (14/19) Installing g++ (6.3.0-r4)
    docker: (15/19) Installing make (4.2.1-r0)
    docker: (16/19) Installing fortify-headers (0.8-r0)
    docker: (17/19) Installing build-base (0.5-r0)
    docker: (18/19) Upgrading musl-utils (1.1.16-r14 -> 1.1.16-r15)
    docker: (19/19) Installing python2-dev (2.7.15-r0)
    docker: Executing busybox-1.26.2-r11.trigger
    docker: OK: 274 MiB in 64 packages
    docker: Collecting pip
    docker:   Downloading https://files.pythonhosted.org/packages/d8/f3/413bab4ff08e1fc4828dfc59996d721917df8e8583ea85385d51125dceff/pip-19.0.3-py2.py3-none-any.whl (1.4MB)
    docker: Installing collected packages: pip
    docker:   Found existing installation: pip 9.0.1
    docker:     Uninstalling pip-9.0.1:
    docker:       Successfully uninstalled pip-9.0.1
    docker: Successfully installed pip-19.0.3
    docker: DEPRECATION: Python 2.7 will reach the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 won't be maintained after that date. A future version of pip will drop support for Python 2.7.
    docker: Requirement already satisfied: awscli in /usr/lib/python2.7/site-packages (1.16.106)
    docker: Requirement already satisfied: s3transfer<0.3.0,>=0.2.0 in /usr/lib/python2.7/site-packages (from awscli) (0.2.0)
    docker: Requirement already satisfied: docutils>=0.10 in /usr/lib/python2.7/site-packages (from awscli) (0.14)
    docker: Requirement already satisfied: botocore==1.12.96 in /usr/lib/python2.7/site-packages (from awscli) (1.12.96)
    docker: Requirement already satisfied: PyYAML<=3.13,>=3.10 in /usr/lib/python2.7/site-packages (from awscli) (3.13)
    docker: Requirement already satisfied: colorama<=0.3.9,>=0.2.5 in /usr/lib/python2.7/site-packages (from awscli) (0.3.9)
    docker: Requirement already satisfied: rsa<=3.5.0,>=3.1.2 in /usr/lib/python2.7/site-packages (from awscli) (3.4.2)
    docker: Requirement already satisfied: futures<4.0.0,>=2.2.0; python_version == "2.6" or python_version == "2.7" in /usr/lib/python2.7/site-packages (from s3transfer<0.3.0,>=0.2.0->awscli) (3.2.0)
    docker: Requirement already satisfied: urllib3<1.25,>=1.20; python_version == "2.7" in /usr/lib/python2.7/site-packages (from botocore==1.12.96->awscli) (1.24.1)
    docker: Requirement already satisfied: python-dateutil<3.0.0,>=2.1; python_version >= "2.7" in /usr/lib/python2.7/site-packages (from botocore==1.12.96->awscli) (2.8.0)
    docker: Requirement already satisfied: jmespath<1.0.0,>=0.7.1 in /usr/lib/python2.7/site-packages (from botocore==1.12.96->awscli) (0.9.3)
    docker: Requirement already satisfied: pyasn1>=0.1.3 in /usr/lib/python2.7/site-packages (from rsa<=3.5.0,>=3.1.2->awscli) (0.4.5)
    docker: Requirement already satisfied: six>=1.5 in /usr/lib/python2.7/site-packages (from python-dateutil<3.0.0,>=2.1; python_version >= "2.7"->botocore==1.12.96->awscli) (1.12.0)
==> docker: Committing the container
    docker: Image ID: sha256:8af22b4e91c0e6ebc53e309ac3d803c989e7007c9e6c3f57dadeda0d059006d6
==> docker: Killing the container: 5fbda610d9117b5a2c20f5da6e77b4cb230114c44fbf79b168a30e32e3bc26f2
==> docker: Running post-processor: docker-tag
    docker (docker-tag): Tagging image: sha256:8af22b4e91c0e6ebc53e309ac3d803c989e7007c9e6c3f57dadeda0d059006d6
    docker (docker-tag): Repository: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container:5
==> docker: Running post-processor: docker-push
    docker (docker-push): Fetching ECR credentials...
    docker (docker-push): Logging in...
    docker (docker-push): Login Succeeded
    docker (docker-push): Pushing: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container:5
    docker (docker-push): The push refers to repository [123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container]
    docker (docker-push): 17073917cb42: Preparing
    docker (docker-push): 96287b9167c6: Preparing
    docker (docker-push): 8619e10b942a: Preparing
    docker (docker-push): e74e4c2ec07f: Preparing
    docker (docker-push): 780b2a6e852d: Preparing
    docker (docker-push): e79522dce35e: Preparing
    docker (docker-push): e79522dce35e: Waiting
    docker (docker-push): 96287b9167c6: Pushed
    docker (docker-push): e79522dce35e: Pushed
    docker (docker-push): 8619e10b942a: Pushed
    docker (docker-push): 780b2a6e852d: Pushed
    docker (docker-push): e74e4c2ec07f: Pushed
    docker (docker-push): 17073917cb42: Pushed
    docker (docker-push): 5: digest: sha256:5407f913fb6493f6d67079b562bfc570775c4a649eaf1ee58c6151abfea0b139 size: 1582
    docker (docker-push): Logging out...
    docker (docker-push): Removing login credentials for 123456789012.dkr.ecr.eu-west-1.amazonaws.com
Build 'docker' finished.

==> Builds finished. The artifacts of successful builds are:
--> docker: Imported Docker image: sha256:8af22b4e91c0e6ebc53e309ac3d803c989e7007c9e6c3f57dadeda0d059006d6
--> docker: Imported Docker image: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container:5
--> docker: Imported Docker image: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-codebuild-container:5
```

So that's an example of nearly every key component to build your Dockerfile. All that's required is a tool to host it in.

!!! Note The Cons

    - Packer build only works with docker images that already have SSH on them.
    - Shell Provisioners - Bash scripts only run if you have Bash installed in your container.
    - Packer Docker builds can't build from 'scratch'.
    - Packer Provisioners use SSH, images like a Base Alpine will fail, so you can only base your containers that have SSH installed.
    - No Layer caching.
