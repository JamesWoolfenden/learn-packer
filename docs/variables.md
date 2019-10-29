# Variables

There are multiple ways use variables with Packer Templates.

## From cmd line

```cli
packer build base.json -var 'region=eu-west-1'
```

## From file

```cli
packer build base.json -var-file en.json
```

Where the env.json looks like:

```json
{
  "instance_type": "t2.micro",
  "vpc_id": "vpc-xxxxxxx",
  "subnet_id": "subnet-xxxxxxx",
  "ami_users": "xxxxxxxxxx",
  "aws_region": "eu-west-1"
}
```

## From Env

Any environmental Variable can be used in the template, to get AWS_ACCESS_KEY_ID:

```json
{{env `AWS_ACCESS_KEY_ID`}}
```

## From Consul

You can access key/value in consul:

```json
{{ consul_key `my/lovely/horse` }}
```

## From Vault

And Secret or sensitive variables from Hashicorp Vault:

```json
{{ vault `/my/secret/lovely` `horse`}}
```
