source "amazon-ebs" "base1604" {
  ami_description= "ubuntu base 16.04"
  ami_name       = "ubuntu-16.04-BASE-v1-{{timestamp}}-AMI"
  ami_users      = var.ami_users
  ami_regions    = var.ami_regions
  ami_virtualization_type= "hvm"
  associate_public_ip_address= var.associate_public_ip_address
  instance_type  = var.instance_type
  region         = var.region
  region_kms_key_ids {
      eu-west-1= "alias/ami-shared"
      eu-west-2= "alias/ami-shared"
    }
  run_tags {
    Name= "ubuntu-base-packer"
    Application= "base"
    OS= "Ubuntu 16.04"
  }
  encrypt_boot  = "true"
  kms_key_id    = "alias/ami-sharing"
  spot_price    = "auto"
  ssh_username  = "ubuntu"
  ssh_interface = "public_ip"
  subnet_id     = var.subnet_id
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
  vpc_id                 = var.vpc_id
  tags {
    OS_Version= "Ubuntu 16.04"
    Version= var.BUILD_NUMBER
    Application= "Ubuntu Image"
    Runner= "EC2"
  }
}
