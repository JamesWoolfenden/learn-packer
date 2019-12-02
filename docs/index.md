# Learn Packer

[![Latest Release](https://img.shields.io/github/v/tag/slalom-consulting-ltd/learn-packer.svg)](https://github.com/JamesWoolfenden/learn-packer-web)

By [James Woolfenden](https://www.linkedin.com/in/jameswoolfenden/)

## What is Packer

Packer is a cross platform and open source machine image creation tool, made by Hashicorp. Packer can make the images that launch our instances.
When the term "**Infrastructure As Code**" is used, it is one of the foundational tools that are
attributed to that term.

Packer can be used to make Machine Images, be they Virtual Machine Server Instances or Containers.
Hashicorps Packer is fully open source and the sourcecode is on Github here
<https://github.com/hashicorp/packer>, and as you can see it is written in
Golang.

As well as examining the code you can see current issues/defects
<https://github.com/hashicorp/packer/issues> and submit your own.

All the examples can be found and copied from <https://github.com/JamesWoolfenden/learn-packer-web/tree/master/examples>

The Packer term "templates" is used to refer to the files passed to the tool, are
JSON files. **base-ami.json** below is a fully fledged AMI creastion example for AWS.

```packer
{
    "variables": {
        "aws_access_key": "{{env `AWS_ACCESS_KEY_ID`}}",
        "aws_secret_key": "{{env `AWS_SECRET_ACCESS_KEY`}}",
        "aws_session_token": "{{env `AWS_SESSION_TOKEN`}}",
        "build_number": "{{env `BUILD_NUMBER`}}",
        "aws-region": "{{env `AWS_REGION`}}"
    },
    "provisioners": [
        {
            "type": "shell",
            "script": "provisioners/scripts/linux/redhat/install_ansible.sh"
        },
        {
            "type": "shell",
            "script": "provisioners/scripts/linux/redhat/install_aws_ssm.sh"
        },
        {
            "type": "ansible-local",
            "playbook_file": "provisioners/ansible/playbooks/cloudwatch-metrics.yml",
            "role_paths": [
                "provisioners/ansible/roles/cloudwatch-metrics"
            ]
        }
    ],
    "builders": [
        {
            "type": "amazon-ebs",
            "access_key": "{{user `aws_access_key`}}",
            "secret_key": "{{user `aws_secret_key`}}",
            "token": "{{user `aws_session_token`}}",
            "region": "{{user `aws_region`}}",
            "source_ami_filter": {
                "filters": {
                    "virtualization-type": "hvm",
                    "name": "RHEL-7.6_HVM_GA-*",
                    "root-device-type": "ebs"
                },
                "owners": [
                    "309956199498"
                ],
                "most_recent": true
            },
            "instance_type": "{{ user `instance_type` }}",
            "ssh_username": "ec2-user",
            "ami_name": "RHEL-BASE-v{{user `build_number`}}-{{timestamp}}-AMI",
            "ami_description": "RHEL base AMI",
            "ami_virtualization_type": "hvm",
            "ami_users": "{{ user `ami_users` }}",
            "temporary_key_pair_name": "rhel-packer-{{timestamp}}",
            "vpc_id": "{{user `vpc_id`}}",
            "subnet_id": "{{user `subnet_id`}}",
            "associate_public_ip_address": true,
            "run_tags": {
                "Name": "rhel-base-packer",
                "Application": "base"
            },
            "tags": {
                "OS_Version": "RedHat7",
                "Version": "{{user `build_number`}}",
                "Application": "Base Image",
                "Runner": "EC2"
            }
        }
    ]
}
```

There is a lot going on there.

That file has three of the four sections you'll find in Packer templates:

- variables

- builders

> Targets what you are making, you can have multiple builds that run in
> parallel.

- Provisioners

> Run after provisioners, these run in order on top of what you are building.

Only a post-processor missing here. A common use of a post-processor would be to
make a Vagrant Image from your builder, or to tag and push your Docker Images to
their Repository. This is achieved by adding a new section to your template,
only certain pst-processors work with each builder:

```packer
{
  "post-processors": ["Vagrant"]
}
```

Packer is on a fairly fast update cycle, what may not have been supported in one
release may get addressed and released. You can stay abreast of the changes via
their changelog.

```packer
$ packer
Usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build       build image(s) from template
    fix         fixes templates from old versions of packer
    inspect     see components of a template
    validate    check that a template is valid
    version     Prints the Packer version

$ packer version
Packer v1.4.4
```

Current release of Packer ![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/hashicorp/packer)

## Why Packer

The rationale for using Packer is for it to help you create image an factory, a
production line for Images, no matter what type to base your infrastructure on.
Creating immutable images, with the only missing piece being environment
specific configuration and keeping that to a minimum. Immutable Images are
expected to be Stateless.

### Why not update the images or Configuration manage the images

In place updates are riskier due to possible downtime, and applying fixes or
updates to your current production Instance and Images could case an outage.
Rollback is problematic with in-place updates. Basing the approach on AMI's gives
you:

- repeatability

- quick boot times

- no reliance on externalities or third parties

- treat images as software artefacts with same CI process and versioning

### What are the alternatives to Packer

Scripting it all yourself using:

- Ansible by itself

- Bash

- Powershell

- SSH

But that's if you like maintaining a large home-grown script codebase.

And more recently:

- AWS imagebuilder

!!!Note Links
    <https://en.wikipedia.org/wiki/Software_release_life_cycle#RTM>
    
    <https://www.hashicorp.com/resources/what-is-mutable-vs-immutable-infrastructure>
    
    <https://aws.amazon.com/about-aws/whats-new/2019/12/introducing-ec2-image-builder>

Made with Mkdocs, for full documentation visit [mkdocs.org](https://mkdocs.org).
