# HCL2

At the Beginning of Feb 2020 Hashicorp announced that they were supporting HCL2 for Packer files. 
They're not dropping support for json.

## What's different and what's better?

The quick answer is that Packer files will a look more like Terraform and so it looks more like code than data- **json**.
Support for all features found in Packer file is not yet complete, but to give you an idea of how they compare, here's a short traditional Windows example with the new format.

.\examples\hcl2vjson1\json1\winserver2019-aws.json

```json
{
  "variables": {
    "aws_access_key": "{{env `AWS_ACCESS_KEY_ID`}}",
    "aws_secret_key": "{{env `AWS_SECRET_ACCESS_KEY`}}",
    "build_number": "{{env `BUILD_NUMBER`}}",
    "instance_type": "t2.micro"
  },
  "builders": [
    {
      "type": "amazon-ebs",
      "access_key": "{{user `aws_access_key`}}",
      "secret_key": "{{user `aws_secret_key`}}",
      "region": "{{user `aws_region`}}",
      "source_ami_filter": {
        "filters": {
          "virtualization-type": "hvm",
          "name": "Windows_Server-2019-English-Full-Base*",
          "root-device-type": "ebs"
        },
        "owners": ["self", "amazon"],
        "most_recent": true
      },
      "instance_type": "{{ user `instance_type` }}",
      "user_data_file": "{{template_dir}}/bootstrap_win.txt",
      "communicator": "winrm",
      "winrm_username": "Administrator",
      "winrm_timeout": "10m",
      "winrm_password": "SuperS3cr3t!!!!",
      "ami_name": "Base v{{user `version`}} Windows2019",
      "ami_description": "Windows 2019 Base",
      "ami_virtualization_type": "hvm",
      "vpc_id": "{{user `vpc_id`}}",
      "subnet_id": "{{user `subnet_id`}}"
    }
  ],
  "provisioners": [
    {
      "type": "powershell",
      "inline": [
        "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))|out-null"
      ]
    },
    {
      "type": "powershell",
      "inline": ["choco install javaruntime -y -force"]
    }
  ]
}
```

In HCL2 this comes[the file extension is required]:

.\examples\hcl2vjson1\hcl2\awswin2k19.pkr.hcl

```hcl
source "amazon-ebs" "Windows2019" {
      region= ""
      instance_type= "t2.micro"
      source_ami_filter {
        filters {
          virtualization-type= "hvm"
          name="Windows_Server-2019-English-Full-Base*"
          root-device-type= "ebs"
        }
        most_recent= true
        owners= ["amazon"]
      }
      ami_name= "Base v1 Windows2019"
      ami_description= "Windows 2019 Base"
      user_data_file= "bootstrap_win.txt"
      communicator= "winrm"
      winrm_username= "Administrator"
      winrm_timeout= "10m"
      winrm_password="SuperS3cr3t!!!!"
      #if empty it uses the default vpc, COMMENTS!!!!
      vpc_id= ""
      subnet_id=""
}

build {
sources =[
   "source.amazon-ebs.Windows2019"
]
 provisioner "powershell" {
    inline = ["iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))|out-null"
      ,"choco install javaruntime -y -force"]
  }
}
```

## Build folders

Packer can now target a folder and build all the **.hcl** files in one folder.
We can seperate the build block into:

*build2win2k19.pkr.hcl*
```
build {
sources =[
   "source.amazon-ebs.Windows2019"
]
 provisioner "powershell" {
    inline = ["iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))|out-null"
      ,"choco install javaruntime -y -force"]
  }
}
```

And build by specifying the folder:
```cli
packer build .\hcl2\
```

So what has changed, besides the brackets and commas?
There's no support for variables yet [it's more alpha than beta] and functions and you can only have one provisioner of each type as yet, but I do think the look is clearer.
It looks like they plan to be able to pass parameters around like you can in Terraform. So this should be a good thing.

- to be continued...
