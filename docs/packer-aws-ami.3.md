# Versioning

For anything more than the basics you should have a "Bakery" a CI tool and process in place that regaular builds new iMages.
A Scenario where AMI's are built routinely.

This creates its own set of problems.

Greatest of which are "How do I know which AMI is the best?", "How do build a new Imagine and Not Break something" and "Which of these Images has been tried and tested?"

The Images/AMIs themselves are a software Artifact and should have a development process like they do.

When we build a Java library and version it, we can do the same if we name or tag it with a Build number. But I already have a git hash? The git hash does identify it, but it doesn't work well with Humans, QA or ordering. Thanks Git.

## A basic numbering Scheme

[You could use semantic versioning or any scheme you like]

Most CI tools provide/expose and environmental variable or BUILD_NUMBER that can be used.

Add a variable to your template, this will to pull the environment variable BUILD_NUMBER into Packer.

```json
  "build_number": "{{env `BUILD_NUMBER`}}",
```

Then modify the AMI name to refelct the new scheme:

```json
  "ami_name": "RHEL-BASE-v{{user `build_number`}}-{{timestamp}}-AMI",
```

With the version in the name you can now refer to it in your Terraform:

```terraform
data "aws_ami" "rhelbase" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-BASE-v${var.version}*"]
  }
}
```

You can also use the same AMI filters in your Packer Template

```packer
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
```

This filter will get the latest RHEL 7.6 that's published by AWS account 309956199498 also known as Red Hat.

## Finding AMI'S

It's much quicker to find AMIS details via the commandline.
(<https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/>)

Via Powershell

```powershell
aws ec2 describe-images --filter Name="name",Values="CentOS7*"|convertfrom-json
aws ec2 describe-images --filter Name="ProductCode",Values="aw0evgkw8e5c1q413zgy5pjce"|convertfrom-json
```

Via Bash

```Bash
aws ec2 describe-images \
 --owners 679593333241 \
 --filters \
 Name=name,Values='CentOS Linux 7 x86_64 HVM EBS\*' \
 Name=architecture,Values=x86_64 \
 Name=root-device-type,Values=ebs \
 --query 'sort_by(Images, &Name)[-1].ImageId' \
 --output text
```

## Sharing AMI's across regions

Packer exposes the property **ami_regions** for this, however it takes an age as it copies the resulting Volumes between regions, so that'll cost you doubly.
It pains me but it might be better to build the same project in each region you need it.

## Sharing to other accounts

Again Packer has a variable for this:

```packer
"ami_users": "{{ user `ami_users` }}",
```

Which I have exposed as a variable. You can add a list of AWS account numbers to share it to. You dont need to have access to those accounts to share it with them.

## Tips

### How to tidy up old AMI's

Packer is great at making an consuming AWS resources, it's not so good at cleaning up after itself when an AMI becomes obsolete.
AWS-Amicleaner from <https://github.com/bonclay7/aws-amicleaner> tries tp solve this issue.

```bash
pip install future
pip install aws-amicleaner
amicleaner --version
```

To tidy up snapshots

```bash
amicleaner --check-orphans --full-report --keep-previous 20
```

```bash
amicleaner --mapping-key tags --mapping-values Application --full-report --keep-previous 20
```
