# Packer-Ansible-Docker

As of writing there’s still no support for running Ansible on Windows [except via WSL], so to
run these examples you will have to have a Mac Or Linux.

## Pre-requisite

Ansible needs to be installed. On Ubuntu thats:

```bash
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

For other platforms refere to or see the Ansible site itself <https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html>

Ansible **Galaxy** is pre-packaged with Ansible.

## How to get an Ansible role

Call Ansible Galaxy to download a role, in this case, a role to install
Terraform:

```shell
$ ansible-galaxy install --roles-path . migibert.terraform
- downloading role 'terraform', owned by migibert
- downloading role from https://github.com/migibert/terraform-role/archive/1.3.tar.gz
- extracting migibert.terraform to /c/code/book/Image-Creation-using-Packer/packer-ansible-docker/migibert.terraform
- migibert.terraform (1.3) was installed successfully
```

You now have a folder **migibert.terraform**.

You can build these up into playbooks and provsioners, I made many of these to make some Confluent/Kafka Images here:
<https://github.com/JamesWoolfenden/packer-by-example/blob/master/packfiles/redhat/confluent-connect.json>

```json
"provisioners": [
        {
            "type": "ansible-local",
            "playbook_file": "provisioners/ansible/playbooks/confluent.yml",
            "role_paths": [
                "provisioners/ansible/roles/openjdk",
                "provisioners/ansible/roles/confluent.common"
            ]
        },
```

where **confluent.yml** is:

```json
---
- hosts: localhost
  become: yes
  become_user: root
  roles:
    - openjdk
    - confluent.common
```
