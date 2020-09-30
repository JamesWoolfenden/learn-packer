# Sharing

## Sharing across regions

You can use Packer and share your AMI across regions, Packer will copy your disk snapshot to the specified region[this will take a while depending on the disk volume size].

Code: <https://github.com/JamesWoolfenden/learn-packer-web/tree/master/examples/share-to-region>

In **amazon-ebs.base1604.pkr.hcl** that's adding "ami_regions = var.ami_regions"

```HCL
source "amazon-ebs" "base1604" {
  ami_description= "ubuntu base 16.04"
  ami_name       = "ubuntu-16.04-BASE-v1-{{timestamp}}-AMI"
  ami_users      = var.ami_users
  ami_regions    = var.ami_regions
  ami_virtualization_type= "hvm"
  associate_public_ip_address= var.associate_public_ip_address
  instance_type  = var.instance_type
  region= var.region
  run_tags {
    Name= "ubuntu-base-packer"
    Application= "base"
    OS= "Ubuntu 16.04"
  }

  spot_price= "auto"
  ssh_username= "ubuntu"
  subnet_id= var.subnet_id
  source_ami_filter {
    filters {
      virtualization-type= "hvm"
      name= "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type= "ebs"
    }
    most_recent= true
    owners= ["099720109477"]
  }
  temporary_key_pair_name= "ubuntu-packer-{{timestamp}}"
  vpc_id= var.vpc_id
  tags {
    OS_Version= "Ubuntu 16.04"
    Version= var.BUILD_NUMBER
    Application= "Ubuntu Image"
    Runner= "EC2"
  }
}
```

and support for the variable file **variables.pkr.hcl** and its' values in **values.auto.pkrvars.hcl**.

```cli
$ packer build  share-to-region/
...
```

### Sharing across accounts

This is similar to regions, add in adding: 

```HCL
ami_users = var.ami_users
```

to **amazon-ebs.base1604.pkr.hcl**, only this won't take as long as the sharing cross region as your are only sharing access to resources, from the other accounts.

Its fairly straight-forward for unencrypted AMIS.

## How to encrypt boot volume of image and share across accounts

### How to encrypt boot volume of image

Add the details of your key you want to create and implement a template using <https://registry.terraform.io/modules/JamesWoolfenden/kms/aws/0.0.3> .

Create the customer KMS key and give it an alias, I used _alias/ami-sharing_

In your **encrypt\amazon-ebs.base1604.pkr.hcl** add:

```hcl
  encrypt_boot  = "true"
  kms_key_id    = "alias/ami-sharing"
```

If you want to build to multiple regions you will need to specify a key for each region:

```hcl
  encrypt_boot  = "true"
  region_kms_key_ids {
      eu-west-1= "alias/ami-sharing"
      eu-west-2= "alias/ami-sharing"
    }
```

With these items included, a build will create an encrypted AMI for the regions specified.

### Create and share a KMS key

This will encrypt the volumes, and the other accounts will need to read it to use the shared AMIS.

Create and share a KMS key using this Terraform module <https://github.com/JamesWoolfenden/terraform-aws-kms>:

```hcl
module "kms" {
  source      = "JamesWoolfenden/kms/aws"
  version     = "0.0.3"
  common_tags = var.common_tags
  key         = var.key
  accounts    = var.accounts
}
```

But add to the list *accounts* specify the accounts you want to share to. 

See the folder **examples/kms** for a fully worked up example.

The module creates a KMS key and shares it between any number of accounts.
_You will need a different key for each region, although the alias can be the same._

```cli
$ packer build encrypt/
amazon-ebs: output will be in this color.

==> amazon-ebs: Prevalidating any provided VPC information
==> amazon-ebs: Prevalidating AMI Name: ubuntu-16.04-BASE-v1-1583705264-AMI
    amazon-ebs: Found Image ID: ami-0a590332f9f499197
==> amazon-ebs: Creating temporary keypair: ubuntu-packer-1583705264
==> amazon-ebs: Creating temporary security group for this instance: packer_5e656cb2-f6b3-eb4f-1e0f-b624af166369
==> amazon-ebs: Authorizing access to port 22 from [0.0.0.0/0] in the temporary security groups...
==> amazon-ebs: Launching a spot AWS instance...
==> amazon-ebs: Interpolating tags for spot instance...
    amazon-ebs: Adding tag: "OS": "Ubuntu 16.04"
    amazon-ebs: Adding tag: "Application": "base"
    amazon-ebs: Adding tag: "Name": "ubuntu-base-packer"
    amazon-ebs: Loading User Data File...
    amazon-ebs: Creating Spot Fleet launch template...
    amazon-ebs: Sending spot request ()...
    amazon-ebs: Instance ID: i-01478606acfeed1e7
==> amazon-ebs: Waiting for SSH to become available...
==> amazon-ebs: Connected to SSH!
==> amazon-ebs: Creating AMI K08fNTm from instance i-01478606acfeed1e7
    amazon-ebs: AMI: ami-0c4cbec3daaf0bac9
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Copying/Encrypting AMI (ami-0c4cbec3daaf0bac9) to other regions...
    amazon-ebs: Copying to: eu-west-1
    amazon-ebs: Copying to: eu-west-2
    amazon-ebs: Waiting for all copies to complete...
==> amazon-ebs: Modifying attributes on AMI (ami-05f8bfd2d13e8257b)...
    amazon-ebs: Modifying: description
==> amazon-ebs: Modifying attributes on AMI (ami-07157019afe1400c8)...
    amazon-ebs: Modifying: description
==> amazon-ebs: Modifying attributes on snapshot (snap-0da1e3fe97a35bb60)...
==> amazon-ebs: Modifying attributes on snapshot (snap-054a565a034ef1102)...
==> amazon-ebs: Adding tags to AMI (ami-05f8bfd2d13e8257b)...
==> amazon-ebs: Tagging snapshot: snap-0da1e3fe97a35bb60
==> amazon-ebs: Creating AMI tags
    amazon-ebs: Adding tag: "Application": "Ubuntu Image"
    amazon-ebs: Adding tag: "OS_Version": "Ubuntu 16.04"
    amazon-ebs: Adding tag: "Runner": "EC2"
    amazon-ebs: Adding tag: "Version": "1"
==> amazon-ebs: Creating snapshot tags
==> amazon-ebs: Adding tags to AMI (ami-07157019afe1400c8)...
==> amazon-ebs: Tagging snapshot: snap-054a565a034ef1102
==> amazon-ebs: Creating AMI tags
    amazon-ebs: Adding tag: "OS_Version": "Ubuntu 16.04"
    amazon-ebs: Adding tag: "Runner": "EC2"
    amazon-ebs: Adding tag: "Version": "1"
    amazon-ebs: Adding tag: "Application": "Ubuntu Image"
==> amazon-ebs: Creating snapshot tags
==> amazon-ebs: Deregistering the AMI and deleting unencrypted temporary AMIs and snapshots
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
eu-west-1: ami-07157019afe1400c8
eu-west-2: ami-05f8bfd2d13e8257b
```

### Encrypt and share across accounts

Update your kms key template account variables and apply, to share the key to the third party accounts.
With the keys updated, and also the value of the list aws-regions with your new target AWS accounts rebuild the packer folder and you will have shared your encrypted ami cross region and cross account.

```packer
 packer build .\encrypt\
amazon-ebs: output will be in this color.

==> amazon-ebs: Prevalidating any provided VPC information
==> amazon-ebs: Prevalidating AMI Name: ubuntu-16.04-BASE-v1-1583750275-AMI
    amazon-ebs: Found Image ID: ami-0a590332f9f499197
==> amazon-ebs: Creating temporary keypair: ubuntu-packer-1583750275
==> amazon-ebs: Creating temporary security group for this instance: packer_5e661c84-fbe2-89df-ad10-e5cad9a12b7d
==> amazon-ebs: Authorizing access to port 22 from [0.0.0.0/0] in the temporary security groups...
==> amazon-ebs: Launching a spot AWS instance...
==> amazon-ebs: Interpolating tags for spot instance...
    amazon-ebs: Adding tag: "Application": "base"
    amazon-ebs: Adding tag: "Name": "ubuntu-base-packer"
    amazon-ebs: Adding tag: "OS": "Ubuntu 16.04"
    amazon-ebs: Loading User Data File...
    amazon-ebs: Creating Spot Fleet launch template...
    amazon-ebs: Sending spot request ()...
    amazon-ebs: Instance ID: i-0457e2990bd585d2d
==> amazon-ebs: Waiting for SSH to become available...
==> amazon-ebs: Connected to SSH!
==> amazon-ebs: Creating AMI zOLxxQ9 from instance i-0457e2990bd585d2d
    amazon-ebs: AMI: ami-0bdae0ecb3c5268e4
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Copying/Encrypting AMI (ami-0bdae0ecb3c5268e4) to other regions...
    amazon-ebs: Copying to: eu-west-2
    amazon-ebs: Copying to: eu-west-1
    amazon-ebs: Waiting for all copies to complete...
==> amazon-ebs: Modifying attributes on AMI (ami-0a6366419738405d6)...
    amazon-ebs: Modifying: description
    amazon-ebs: Modifying: users
==> amazon-ebs: Modifying attributes on AMI (ami-02e9526bdb3fe0179)...
    amazon-ebs: Modifying: users
    amazon-ebs: Modifying: description
==> amazon-ebs: Modifying attributes on snapshot (snap-08419a36afff3d151)...
==> amazon-ebs: Modifying attributes on snapshot (snap-05233b62e73920cbd)...
==> amazon-ebs: Adding tags to AMI (ami-0a6366419738405d6)...
==> amazon-ebs: Tagging snapshot: snap-08419a36afff3d151
==> amazon-ebs: Creating AMI tags
    amazon-ebs: Adding tag: "OS_Version": "Ubuntu 16.04"
    amazon-ebs: Adding tag: "Runner": "EC2"
    amazon-ebs: Adding tag: "Version": "1"
    amazon-ebs: Adding tag: "Application": "Ubuntu Image"
==> amazon-ebs: Creating snapshot tags
==> amazon-ebs: Adding tags to AMI (ami-02e9526bdb3fe0179)...
==> amazon-ebs: Tagging snapshot: snap-05233b62e73920cbd
==> amazon-ebs: Creating AMI tags
    amazon-ebs: Adding tag: "Version": "1"
    amazon-ebs: Adding tag: "Application": "Ubuntu Image"
    amazon-ebs: Adding tag: "OS_Version": "Ubuntu 16.04"
    amazon-ebs: Adding tag: "Runner": "EC2"
==> amazon-ebs: Creating snapshot tags
==> amazon-ebs: Deregistering the AMI and deleting unencrypted temporary AMIs and snapshots
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
eu-west-1: ami-02e9526bdb3fe0179
eu-west-2: ami-0a6366419738405d6
```