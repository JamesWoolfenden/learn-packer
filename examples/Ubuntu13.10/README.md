# packer-ubuntu.1310

This was based on a rather aged example from flomotlik, you can see his original repository flomotlik/packer-example <https://github.com/flomotlik/packer-example>.
I have only changed what I had to (Checksums and types).
Obviously Ubuntu 13 is not that useful these days, but it does illustrate some of differences in the packer templates
that need to addressed in for Virtual box and an Ubuntu install, namely:

- boot_command and ubiquity
- http and the preseed

I also had to modify the root_setup.sh file as Ubuntu13 is EOL so its repos are cached elsewhere.
This is handled by modifying the sources.list file.

```bash
sudo sed -i 's/us.archive/old-releases/g' /etc/apt/sources.list
sudo sed -i 's/\/security/\/old-releases/g' /etc/apt/sources.list
```

I also removed a whole bunch of extraneous ruby, node, redis and postgres packages. That's way to implementation specific.

My source is available here:
<https://github.com/JamesWoolfenden/packer-example>

You can use as is or you can add a post processor, you can add a Vagrant (there's quite a bit of left over support in the preseed)
easily:

```packer
  "post-processors": [
    "vagrant"
  ],

```
