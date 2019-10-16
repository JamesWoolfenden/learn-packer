# Post-processor

If can add a post-processor section to your packer templates. In this case add a Vagrant to an Ubuntu AMI build

```json
"post-processors": ["vagrant"]
```

So you end with **base-aws.tovagrant.json**

```json
{
    "variables": {
        "aws_access_key": "{{env `AWS_ACCESS_KEY_ID`}}",
        "aws_secret_key": "{{env `AWS_SECRET_ACCESS_KEY`}}",
        "aws_session_token": "{{env `AWS_SESSION_TOKEN`}}",
        "build_number": "{{env `BUILD_NUMBER`}}",
        "aws-region": "{{env `AWS_REGION`}}",
        "instance_type": "t2.micro"
    },
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
    ],
    "post-processors": ["vagrant"]
}
```

When you run this template with this section added:

```cli
packer build .\base-aws.tovagrant.json
```

```cli
amazon-ebs output will be in this color.

==> amazon-ebs: Prevalidating AMI Name: RHEL-BASE-v-1553515786-AMI
    amazon-ebs: Found Image ID: ami-0202869bdd0fc8c75
==> amazon-ebs: Creating temporary keypair: rhel-packer-1553515786
==> amazon-ebs: Creating temporary security group for this instance: packer_5c98c50d-5cea-f8fa-e4f9-190bbb536434
==> amazon-ebs: Authorizing access to port 22 from 0.0.0.0/0 in the temporary security group...
==> amazon-ebs: Launching a source AWS instance...
==> amazon-ebs: Adding tags to source instance
    amazon-ebs: Adding tag: "Application": "base"
    amazon-ebs: Adding tag: "Name": "rhel-base-packer"
    amazon-ebs: Instance ID: i-03777753ff9da5a90
==> amazon-ebs: Waiting for instance (i-03777753ff9da5a90) to become ready...
==> amazon-ebs: Using ssh communicator to connect: 54.229.138.43
==> amazon-ebs: Waiting for SSH to become available...
==> amazon-ebs: Connected to SSH!
==> amazon-ebs: Stopping the source instance...
    amazon-ebs: Stopping instance, attempt 1
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating unencrypted AMI RHEL-BASE-v-1553515786-AMI from instance i-03777753ff9da5a90
    amazon-ebs: AMI: ami-09e36b5de41d52201
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Modifying attributes on AMI (ami-09e36b5de41d52201)...
    amazon-ebs: Modifying: description
==> amazon-ebs: Modifying attributes on snapshot (snap-03c17a67bf38f946f)...
==> amazon-ebs: Adding tags to AMI (ami-09e36b5de41d52201)...
==> amazon-ebs: Tagging snapshot: snap-03c17a67bf38f946f
==> amazon-ebs: Creating AMI tags
    amazon-ebs: Adding tag: "Version": ""
    amazon-ebs: Adding tag: "Application": "Base Image"
    amazon-ebs: Adding tag: "Runner": "EC2"
    amazon-ebs: Adding tag: "OS_Version": "RedHat7"
==> amazon-ebs: Creating snapshot tags
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
==> amazon-ebs: Running post-processor: vagrant
==> amazon-ebs (vagrant): Creating Vagrant box for 'aws' provider
    amazon-ebs (vagrant): Compressing: Vagrantfile
    amazon-ebs (vagrant): Compressing: metadata.json
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
eu-west-1: ami-09e36b5de41d52201

--> amazon-ebs: 'aws' provider box: packer_amazon-ebs_aws.box
```

You get your regular ami made plus you notice that the last few lines are different from usual build and outputs and leaves you with a binary file
**packer_amazon-ebs_aws.box**.

This can be added to your Vagrant with:

```cli
vagrant box add fancy-box packer_amazon-ebs_aws.box
```

```cli
vagrant box add fancy
-box packer_amazon-ebs_aws.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'fancy-box' (v0) for provider:
    box: Unpacking necessary files from: file://C:/code/book/Image-Creation-using-Packer/packer-ami/amazon-ebs/linux/packer_amazon-ebs_aws.box
    box: Progress: 100% (Rate: 349k/s, Estimated time remaining: --:--:--)
==> box: Successfully added box 'fancy-box' (v0) for 'aws'!
```

Amazing!
