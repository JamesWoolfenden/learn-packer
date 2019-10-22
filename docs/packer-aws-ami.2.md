# Advanced AWS authentication

There are a number of more sophisticated authentication schemes for AWS. These all require an extra environmental variable - AWS_SESSION_TOKEN.

```cli
AWS_ACCESS_KEY_ID=xxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxx
AWS_SESSION_TOKEN=xxxxxxxxxxxx
```

The templates need an extra variable:

```packer
   "aws_session_token": "{{env `AWS_SESSION_TOKEN`}}",
```

and to the EBS builder we add:

```packer
  "token": "{{user `aws_session_token`}}",
```

## Assumed roles

A common AWS IAM usage pattern is to create roles that can be assumed by users, either in the same AWS account or as "cross account roles".

Assuming roles isn't yet supported directly in Packers EBS builder syntax, so for now there are two well established external methods for using assumed roles:

### Via scripts

You can create your AWS credentials on-the-fly by calling this Powershell or a bash function and then create the environment variables to run Packer.

```powershell
function iam_assume_role
{
  <#
  .Description
  iam_assume_role allows you to run as a different role in a different account

  .Example
   iam_assume_role -AccountNo $AccountNo -Role SuperAdmin
#>
   Param(
     [Parameter(Mandatory=$true)]
     [string]$AccountNo,
     [Parameter(Mandatory=$true)]
     [string]$Role
   )

   Write-Output "AccountNo: $AccountNo"
   Write-Output "Role     : $Role"

   $ARN="arn:aws:iam::$($AccountNo):role/$Role"
   Write-Output "ARN      : $ARN"
   Write-Output "aws sts assume-role --role-arn $ARN --role-session-name $SESSION_NAME --duration-seconds 3600"
   $Creds=aws sts assume-role --role-arn $ARN --role-session-name $SESSION_NAME --duration-seconds 3600 |convertfrom-json

   [Environment]::SetEnvironmentVariable("AWS_DEFAULT_REGION","eu-west-2")
   [Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID",$creds.Credentials.AccessKeyId)
   [Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY",$creds.Credentials.AccessKeyId)
   [Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY",$creds.Credentials.SecretAccessKey)
   [Environment]::SetEnvironmentVariable("AWS_SECRET_KEY", $creds.Credentials.SecretAccessKey)
   [Environment]::SetEnvironmentVariable("AWS_SESSION_TOKEN",$creds.Credentials.SessionToken)
}
```

This achieves the same in Bash:

```bash
# Clear out existing AWS session environment, or the awscli call will fail
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN

# Old ec2 tools use other env vars
unset AWS_ACCESS_KEY AWS_SECRET_KEY AWS_DELEGATION_TOKEN

ROLE="${1:-SecurityMonkey}"
ACCOUNT="${2:-123456789}"
DURATION="${3:-900}"
NAME="${4:-$LOGNAME@$(hostname -s)}"
ARN="arn:aws:iam::${ACCOUNT}:role/$ROLE"
ECHO "ARN: $ARN"

KST=($(aws sts assume-role --role-arn "$ARN" \
                          --role-session-name "$NAME" \
                          --duration-seconds "$DURATION" \
                          --query "[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]" \
                          --output text))

echo "export AWS_DEFAULT_REGION=\"eu-west-2\""
echo "export AWS_ACCESS_KEY_ID=\"${KST[0]}\""
echo "export AWS_ACCESS_KEY=\"${KST[0]}\""
echo "export AWS_SECRET_ACCESS_KEY=\"${KST[1]}\""
echo "export AWS_SECRET_KEY=\"${KST[1]}\""
echo "export AWS_SESSION_TOKEN='${KST[2]}'"
```

Then when you run Packer it can use the credentials of the assumed role.

### Via AWS-Vault

AWS Vault is very handy tool for managing authentication to multiple accounts and roles.

It comes from **99designs**[Thanks Folks] and can found here <https://github.com/99designs/aws-vault>. The tool generates the same environmental variables as the scripts and also encrypts and password controls your access. This is great for local development. I've used this solution on a number of projects.

### Federated Authentication

If your AWS account is set-up to use a federated Authentication scheme (Active Directory), your account may have no IAM users. Having no users specified makes it difficult to create access keys, and by difficult I really mean impossible. Do not then bypass your mandated security procedure and add some IAM users in.

How can I work?

The command line tool  **saml2aws** <https://github.com/Versent/saml2aws> solves exactly this problem, it allows you to set up multiple profiles and then login to those profiles.
It then updates your .aws configuration with temporary AWS credentials. You can then continue as before but either set the default profile or use named profiles.

### Via AWS IAM instance profile

So far all the methods we have covered are aimed at how to get authentication for developing with Packer, but not for operational use.
Operationally I would expect you to be running packer thru a Continuos Integration Server and build new AMIs as code changes or when the base AMIS they are made from are patched and released (Monthly).
If you want to run packer in an automated fashion then the authentication needs to be provided as an IAM Instance Profile.
Use the role already given but use the following to make an Instance Profile that can be used by EC2 instances.

```terraform
resource "aws_iam_instance_profile" "packer" {
  name = "packer"
  role = aws_iam_role.packer.name
}
```

You can then connect your new IAM instance profile to your EC2 instance :
**aws_instance.packer.tf** below demonstrate how to tie it all together:

```terraform
resource "aws_instance" "packer" {
  ami                         = data.aws_ami.ubuntu.image_id
  iam_instance_profile        = aws_iam_instance_profile.packer.name
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.packer.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.packer.key_name
  user_data                   = "${file("${path.module}/files/userdata.sh")}"
  subnet_id                   = var.subnet_id

  tags = var.common_tags
}
```

If you provision this instance it should have the permission packer requires.
