# build hello world

 info https://www.digitalocean.com/community/tutorials/how-to-build-go-executables-for-multiple-platforms-on-ubuntu-16-04
 set to build for linux on amd64

## windows

``` powershell
$env:GOOS="linux"
$env:GOARCH="amd64"
go build .
```

## not windows

env GOOS=linux GOARCH=amd64 go build

## docker

docker build .
docker run 6159594e740f
hello world

## packer docker

Unfortunately at the time of writing you cant create containers using scratch as your base, so the example uses ubuntu.

```packer
packer validate hello-world.json
```

if thats good then build it.

```packer
packer build hello-world.json
```
