# Installing Packer

Packer is a system for creating images and multiple image types from a single file.
Manual Installation instructions are well documented on the Packer website.
Packer like Terraform, is frequently updated with new features, as well
as fixes, which are well documented in its changelog
<https://github.com/hashicorp/packer/blob/master/CHANGELOG.md>.

Or you could submit your new feature or fix yourself.

## Automated Installation options

``` mac tab="mac"
brew install packer
```

``` powershell tab="powershell"
cinst packer
```

``` bash tab="linux"
#!/bin/bash
set -exo
curl https://keybase.io/hashicorp/pgp_keys.asc | gpg --import
apt-get install unzip
VERSION="1.3.5"
TOOL="packer"
EDITION="linux_amd64"
cd /usr/local/bin
# Download the binary and signature files.
wget "https://releases.hashicorp.com/$TOOL/$VERSION/${TOOL}_${VERSION}_${EDITION}.zip"
wget "https://releases.hashicorp.com/$TOOL/$VERSION/${TOOL}_${VERSION}_SHA256SUMS"
wget "https://releases.hashicorp.com/$TOOL/$VERSION/${TOOL}_${VERSION}_SHA256SUMS.sig"

# Verify the signature file is untampered.
gpg --verify "${TOOL}_${VERSION}_SHA256SUMS.sig" "${TOOL}_${VERSION}_SHA256SUMS"

#only check against your tool
sed '/linux_amd64/!d' ${TOOL}_${VERSION}_SHA256SUMS
sed '/linux_amd64/!d' ${TOOL}_${VERSION}_SHA256SUMS > ${TOOL}_${VERSION}_${EDITION}_SHA256SUMS

# Verify the SHASUM matches the binary.
shasum -a 256 -c "${TOOL}_${VERSION}_${EDITION}_SHA256SUMS"

unzip "${TOOL}_${VERSION}_linux_amd64.zip"
rm "${TOOL}_${VERSION}_linux_amd64.zip"
rm "${TOOL}_${VERSION}_SHA256SUMS"
rm "${TOOL}_${VERSION}_${EDITION}_SHA256SUMS"
rm "${TOOL}_${VERSION}_SHA256SUMS.sig"

"${TOOL}" --version
```

Brew and Chocolatey repositories for Packer are usually up to date.

Packer is published to **yum** and **apt-get** repositories but these installs
require a substantial number of dependencies and can be quite out of date. At this time for Ubuntu 18 repository has v1.0.3 but v1.3.5 is current.

### Docker container

You can also you use Packer from a container

```docker
docker pull hashicorp/packer

docker images
REPOSITORY                                                             TAG                 IMAGE ID            CREATED             SIZE
hashicorp/packer                                                       latest              2453d5a18479        2 weeks ago         167MB
```

You can run it much line the regular cmdline.

```cli
docker run 2453d5a18479 --version
1.35
```

Or

```cli
docker run -i -t hashicorp/packer:light validate
```

You will need to pass in the Packer files by sharing the host folder into Packers Container.

```docker
docker run -v
/c/code/book/packer/01-installing-packer/:/home/docker/
hashicorp/packer:light validate /home/docker/empty.json
``

But when you run the build:

```docker
docker run -v
/c/code/book/packer/01-installing-packer/:/home/docker/
hashicorp/packer:light build /home/docker/empty.json
```

You get:

```cli
Build 'docker' errored: exec: "docker": executable file not found in
\$PATH

==\> Some builds didn't complete successfully and had errors: --\> docker: exec:
"docker": executable file not found in \$PATH

==\> Builds finished but no artifacts were created.
```

Which is confusing until you realise/remember that all that's in that container
is Packer and not Docker. So while you could use a Packer image to build your
containers you'd have to add and customise your own anyway.

## Packer from source code

You can build your own, if you are building from source, use at least version 1.12 of go-lang and follow the instructions from their readme.

Assuming you have \>= 1.12 golang
<https://github.com/hashicorp/packer/blob/master/.github/CONTRIBUTING.md\#setting-up-go-to-work-on-packer>

Just run **go get** and wait.

```golang
go get github.com/hashicorp/packer
cd \$gopath

$ packer -version
1.35
```

!!! Note "Debugging"
    
    You can run Packer in Debug mode using the **-debug** flag, it's fairly verbose but it is particularly useful. If you need to see which AWS call fails and/or to get the temporary SSH key that's can be used to connect to the box used to make your AMI?

    It'll happen.
