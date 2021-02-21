# Building an ISO image with Packer

!!!Note "AVOID"
OK Building ISOs takes time and patience and is super fiddly.
There's much better ways to spend your time. You can download these prebuilt from
Canonical. [cloud-images.ubuntu.com](http://cloud-images.ubuntu.com/)

You can make ISO/disc images for Virtual machine platforms using a number of
Packer builders, I'm going to give a number of examples for VirtualBox and
Ubuntu:-

## Virtualbox ISO

The first example is to build a very basic Ubuntu vbox.

**virtualbox-ubuntu.json**.

```json
{
  "builders": [
    {
      "type": "virtualbox-iso",
      "guest_os_type": "Ubuntu_64",
      "iso_url": "",
      "iso_checksum": "",
      "iso_checksum_type": "sha256",
      "ssh_username": "packer",
      "ssh_password": "packer",
      "shutdown_command": "echo 'packer' | sudo -S shutdown -P now"
    }
  ]
}
```

This is far from complete, the first thing we need to add is what Ubunt ISO to
load, and then to also provide the checksums, that's SHA256 these days.

Ubuntu 16.04 can be found from its release location -
<http://releases.ubuntu.com/16.04/ubuntu-16.04.6-server-amd64.iso>.

And checksum - the SHA256 can be retrieved from
<http://releases.ubuntu.com/16.04/SHA256SUMS>

```SHA256
16afb1375372c57471ea5e29803a89a5a6bd1f6aabea2e5e34ac1ab7eb9786ac
```

Update your packer template, it should now look like this
**virtualbox-ubuntu.json**.

```json
{
  "builders": [
    {
      "type": "virtualbox-iso",
      "guest_os_type": "Ubuntu_64",
      "iso_url": "http://releases.ubuntu.com/16.04/ubuntu-16.04.6-server-amd64.iso",
      "iso_checksum": "16afb1375372c57471ea5e29803a89a5a6bd1f6aabea2e5e34ac1ab7eb9786ac",
      "iso_checksum_type": "sha256",
      "ssh_username": "packer",
      "ssh_password": "packer",
      "shutdown_command": "echo 'packer' | sudo -S shutdown -P now"
    }
  ]
}
```

Time to try it out.

```cli
packer build virtualbox-ubuntu.json
```

Depending on your available bandwidth, it's going to run a while as it down
loads the ISO. virtualbox-iso output will be in this color.

```cli
==> virtualbox-iso: Retrieving Guest additions
    virtualbox-iso: Using file in-place: file:///C:/Program%20Files/Oracle/VirtualBox/VBoxGuestAdditions.iso
==> virtualbox-iso: Retrieving ISO
1 items:  873.00 MiB / 873.00 MiB  4m2s
    virtualbox-iso: Transferred: http://releases.ubuntu.com/16.04/ubuntu-16.04.6-server-amd64.iso
==> virtualbox-iso: Creating virtual machine...
==> virtualbox-iso: Creating hard drive...
==> virtualbox-iso: Creating forwarded port mapping for communicator (SSH, WinRM, etc) (host port 2749)
==> virtualbox-iso: Starting the virtual machine...
==> virtualbox-iso: Waiting 10s for boot...
==> virtualbox-iso: Typing the boot command...
==> virtualbox-iso: Using ssh communicator to connect: 127.0.0.1
==> virtualbox-iso: Waiting for SSH to become available...
```

Yes I ran it from a Windows 10 PC.
A smart move would be to save these ISO locally, and use them from there.

So the output has halted but you should see that Virtual box is running, should
look a bit like this:

It would be unfair at this point if I didnt indicate that the process was yet
fully automated, running packer now would boot your VM but leave it waiting for
you to answer and supply values to the installer. What's the point of that, not
much DevOps there?

The crucial missing part of the puzzle, is the **boot_command** and the **preseed**
file.
These are the instructions provided to the VM that answer or configure
the machine image, well for this builder and OS it's:

```json
         "boot_command": [
            "",
            "",
            "",
            "/install/vmlinuz",
            " auto",
            " console-setup/ask_detect=false",
            " console-setup/layoutcode=us",
            " console-setup/modelcode=pc105",
            " debconf/frontend=noninteractive",
            " debian-installer=en_US",
            " fb=false",
            " initrd=/install/initrd.gz",
            " kbd-chooser/method=us",
            " keyboard-configuration/layout=USA",
            " keyboard-configuration/variant=USA",
            " locale=en_US",
            " netcfg/get_domain=vm",
            " netcfg/get_hostname=vagrant",
            " grub-installer/bootdev=/dev/sda",
            " noapic",
            " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
            " -- ",
            ""
            ],
```

The Boot command is composed of a number of different pieces, here it is:
<https://www.packer.io/docs/builders/virtualbox-iso.html>

It may take some significant effort to get the **boot_command** correct, you may
find a significant number of the samples on the internet do not work.

### Pre-seed file

In the **boot_command** was a reference:

```json
"preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
```

Validate your new template:

```cli
packer validate virtualbox-ubuntu.json
```

```cli
Template validated successfully.
```

That's all working fine, we can try building now.

```cli
packer build virtualbox-ubuntu.json.json
```

### Troubleshooting the virtual box builder

Running virtual-box on Windows: If you get errors of the type "VirtualBox Won't
Run - raw-mode unavailable courtesy of Hyper-V" then you need to run this
command at your console as admin:

```cli
bcdedit /set hypervisorlaunchtype off
```

If your running Hyperv for other reasons (i.e. Docker) you will need to revert
this later:

```cli
bcdedit /set hypervisorlaunchtype auto
```

### Ubuntu specific

### Fails to reboot and waits

There are at 2 layers of automation ended into the ubuntu installer.

- Debian - d-i and tghe preseed.ccg file.

- Ubiquity from Ubuntu

To get it to reboot add this to your preseed.cfg file:

```json
# dont prompt
d-i finish-install/reboot_in_progress note
ubiquity ubiquity/summary note
ubiquity ubiquity/reboot boolean true
```

and this to your packer **boot_command**

```json
" automatic-ubiquity<wait>",
" ubiquity/reboot=true<wait>",
```

### "sudo: sorry, you must have a tty to run sudo"

This was easier to fix, add this line to packer virtualbox

```json
"ssh_pty": "true",
```

Also adding a script Provisioner

```json
{
  "type": "shell",
  "execute_command": "echo '{{user `ssh_pass`}}' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'",
  "inline": ["echo '%sudo ALL=(ALL) NOPASSWD:ALL'>> /etc/sudoers"]
}
```
