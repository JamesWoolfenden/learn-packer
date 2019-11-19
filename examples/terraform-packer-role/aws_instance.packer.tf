resource "aws_instance" "packer" {
  ami                         = data.aws_ami.ubuntu.image_id
  iam_instance_profile        = aws_iam_instance_profile.packer.name
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.packer.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.packer.key_name
  user_data                   = file("${path.module}/files/userdata.sh")
  subnet_id                   = var.subnet_id

  tags = var.common_tags
}
