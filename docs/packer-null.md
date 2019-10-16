# Null builders

This builder does Null or actually nothing. What's the use in that? Well sometimes you want to test some other part a provisioner or post-processor and not wait 10 minutes for a build to run.
It also does cost anything to run.

**packer-null.json** is the minimal configuration possible.

```packer
{
    "builders": [
      {
        "type":         "null",
        "communicator": "none"
      }
    ]
}
```

Then if you run it:

```output
null output will be in this color.

Build 'null' finished.

==> Builds finished. The artifacts of successful builds are:
--> null: Did not export anything. This is the null builder
```

Hopefully i set your expectations low, so no suprises.
A null communicator is not that helpful, but you can set a few other parameters.
You can set the builder to talk to an existing instance:

```packer
  "ssh_username": "scott",
  "ssh_password": "tiger",
  "ssh_host":     "10.0.0.1"
```

So you can now imagine there are some scenarios where it does make some sense after all, as it will save you time and money (especially if making AMIs).

## Examples with Provisioners

### File

Try making and running **packer-null-file.json**

```packer
{
    "builders": [
        {
            "type": "null",
            "ssh_username": "pogo",
            "ssh_password": "BigYellowHair",
            "ssh_host":     "192.168.1.139"
        }
    ],
    "provisioners": [
        {
            "type": "file",
            "source": "hello-world.sh",
            "destination": "hello-world.sh"
        }
    ]
}

Should gives you:
```shell
null output will be in this color.

==> null: Using ssh communicator to connect: 192.168.1.139
==> null: Waiting for SSH to become available...
==> null: Connected to SSH!
==> null: Uploading hello-world.sh => hello-world.sh
1 items:  30 B / 30 B [=============================================================================================] 0s
Build 'null' finished.

==> Builds finished. The artifacts of successful builds are:
--> null: Did not export anything. This is the null builder
```

### Shell-local

Try making and running **packer-null-shell-local.json**

```packer
{
    "builders": [
        {
            "type": "null",
            "ssh_username": "sshd",
            "ssh_password": "HAx0rDude5",
            "ssh_host":     "192.168.1.12"
        }
    ],
    "provisioners": [
        {
            "type": "shell-local",
            "inline": "echo hello world"
        }
    ]
}
```

Running this simple example you get:

```shell
$ packer build packer-null-script.1.json
null output will be in this color.

==> null: Using ssh communicator to connect: 192.168.1.139
==> null: Waiting for SSH to become available...
==> null: Connected to SSH!
==> null: Running local shell script: /tmp/packer-shell769974643
    null: hello world
Build 'null' finished.

==> Builds finished. The artifacts of successful builds are:
--> null: Did not export anything. This is the null builder
```

So as you can see the NULL provisioner is a useful development and testing tool to aid packer template development.

### File builder

Another odd one for the development pile, allowa you to test post-processors quickly.

```json
{
    "builders": [
        {
            "type": "file",
            "content": "# File Header \n multi-line also \n The End",
            "target":  "README.md"
        }
    ]
}
```
