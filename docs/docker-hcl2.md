# Packer-Docker HCL2

Using Packer to build Docker might seem a bit strange at first. Aren't Dockerfiles a standard for building Docker containers?
I'd be thinking this'll never fly with my JS developers? But It can make sense.

To build with a Dockerfile, and to save to it to a registry requires 2 steps, first to build with a CI tool like Gitlab/Circle and requires a Dockerfile and a process to manage logging into the registry and pushing to it.

In Packer this entire process can be captured in one file, encapsulating all that's required, and as a bonus the whole process is runnable locally. Which make for quick debug cycle times.

Using Packer also allows the use and re-use of scripts and to use Ansible role and playbooks as used in other platform builds.

These HCL2 based examples target folders not individual files.

## A very basic Packer Docker template

Starting really simple with **examples-hcl/packer-docker-ubuntu**, this contains a source **docker.base1604.pkr.hcl** 

From examples\packer-docker-ubuntu at <https://github.com/jamesWoolfenden/learn-packer-web/>.

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
Add this section to **build.base1604.pkr.hcl** after the sources [examples\packer-docker-post].

```HCL
post-processor "docker-tag" {
  repository="james"
      tag= ["0.1"]
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

## Building into an AWS registry

```hcl
TODO
```

When this runs in Packer...

```cli
``

With Shell provisioner

## Provisioners

Push to ECR

!!! Note The Cons

    - Packer build only works with docker images that already have SSH on them.
    - Shell Provisioners - Bash scripts only run if you have Bash installed in your container.
    - Packer Docker builds can't build from 'scratch'.
    - Packer Provisioners use SSH, images like a Base Alpine will fail, so you can only base your containers that have SSH installed.
    - No Layer caching.
