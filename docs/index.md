# Learn Packer

Author: James Woolfendnen

------------

When I started in this field, we hardly if ever thought about Servers. I was
working in application development, we made applications and almost as an
afterthought we made installers.

When we were ready, we burnt the installers to CD or even DVD, and we were done
and waited for QA.

If our effort ever passed QA we made went "GOLD MASTER" or Release to
Manufacture (RTM). Releases took months.

In order to test our applications, we needed a known clean state, and to achieve
this clean slate we used tools like Norton Ghost to reset our disks and our OS.
I could then test the installer and applications again, and more importantly we
could repeat.

I started writing scripts to try an automate this process, and to ensure that
the process was repeatable. Later on the tools changed and it was VMs against
VMWare. With VMWare came snapshots and scripting the installation of components,
.dot net frameworks and drivers. I wrote a lot of scripts. The scripts started
getting complex and then we started making sure that our scripts were
Idempotent.

Idempotent is defined by the OED as "Denoting an element of a set which is
unchanged in value when multiplied or otherwise operated on by itself.", in this
context and layman terms, it's designed to be re-runnable.

I wrote a lot of Idempotent scripts too (Bash, Ant, MSBuild and PowerShell
mostly). Then Puppet and Chef arrived, the First Generation of "DevOps" Tooling.
This helped give a framework to work with - a DSL or a Domain Specific Language.
We also has to install a lot of agents, and master control servers as well. We
shared more and we wrote less, but Ruby now.

It was getting easy to make servers and easier to make New Environments. I could
make new environments reliably and I could also decommission them, only being
limited by the infrastructure made available.

We started worrying about people changing our Servers (Ok Developers). How do we
Manage the Configuration and get to a know and recorded state, to fix the
"Drift". The difference from the desired state.

All these Puppet and Chef scripts looked to manage Drift, the tools would then
try to eliminate Drift and bring of environments back to the "Desired State".

We'll we'd try to that is, but it's only as good as the Ruby code you wrote and the packages
they ran, how can you know all the cases/paths that describe how your state could
deviate?

Wouldn't it be better if I didn't have to? And besides some of these Configuration Management (CM) script
suites took a really long time to run, hours. If you wanted to add one new
package to a server or build agent. Agents everywhere. Running them in Prod was
just scary.

Then came the Cloud.

A common API to make our infrastructure against, and no limits? [Just cost
now but we found that out]. Now were using Ansible, all those agents were gone, but it still took
quite some time to make or update our. Wouldn't it be better to make these in
advance? That would be quicker? What about just making new servers quickly from
AMIs instead and just the Environmental configuration at Launch?

When Ansible arrived we no longer had to add Agents/services but we still had to
wait while Ansible built or checked the images. You could use Ansible to make
AMIs directly but Packer is designed to solve just this problem.
Packer with scripts is great, Packer with Ansible is even easier.

## What is Packer

Packer is an open source image creation tool made by Hashicorp, when the term
"Infrastructure As Code" is used, it is one of the foundational tools that are
attributed to that term.

It can be used to make Machine Images be they Server Instances or Containers.
Hashicorp Packer is fully open source and the sourcecode is on Github here
<https://github.com/hashicorp/packer>, and as you can see it is written in
Golang. As well as examining the code you can see current issues/defects
<https://github.com/hashicorp/packer/issues> and submit your own.

Packer use the term "templates" to refer to the files passed to the tool, are
JSON files. **base-ami.json** below is a fully fledged AMI's example.

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

There is lot going there, but I'm going to take you through it all.

That file has three of the four sections you find in Packer templates:

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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ packer version
Packer v1.3.5
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

## Why Packer

The rationale for using Packer is for it to help you create image an factory, a
production line for Images, no matter what type to base your infrastructure on.
Creating immutable images, with the only missing piece being environment
specific configuration and keeping that to a minimum. Immutable Images are
expected to be Stateless.

### Why not update the images or Configuration manage the images we have?

In place updates are riskier due to possible downtime, and applying fixes or
updates to your current production Instance and Images could case an outage.
Rollback is problematic with in-place updates. Basing the approach on AMI's gives
you:

- repeatability

- quick boot times

- no reliance on externalities or third parties

- treat images as software artifacts with same CI process and versioning

### What are the alternatives to Packer

Scripting it all yourself using:

- Ansible by itself

- Bash

- Powershell

But that's if you like maintaining a large homegrown script codebase.

### Links

<https://en.wikipedia.org/wiki/Software_release_life_cycle#RTM>

<https://www.hashicorp.com/resources/what-is-mutable-vs-immutable-infrastructure>

## Project layout

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        installing-packer.md # Install the tool.
        packer-aws-ami.md # Building AMI's
        packer-aws-ami.2.md # Advanced AWS authentication
        packer-aws-ami.3.md # AMI Versioning

Make with mkdocs, for full documentation visit [mkdocs.org](https://mkdocs.org).
