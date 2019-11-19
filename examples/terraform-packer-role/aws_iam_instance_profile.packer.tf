resource "aws_iam_instance_profile" "packer" {
  name = "packer"
  role = aws_iam_role.packer.name
}
