############################### EC2 and Security Group #########################################

resource "aws_security_group" "aws_github_runners_securitygroup" {
  name        = "AWS GitHub Runners Security Group"
  description = "AWS GitHub Runners Security Group"
  vpc_id      = "vpc-0cc923593f8d9050f"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "AWS GitHub Runners Security Group"
  }
}

resource "aws_security_group_rule" "aws_github_runners_securitygroup_allow22" {
  type              = "ingress"
  description       = "Allow Port 22 from Internet"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws_github_runners_securitygroup.id
}

resource "aws_iam_role" "aws_github_runner_role" {
  name               = "aws-github-runner-role"
  assume_role_policy = file("${path.module}/../templates/iam/aws-github-runners/ec2-assumerole-policy.json")
}

resource "aws_iam_instance_profile" "aws_github_runner_instanceprofile" {
  name = "aws_github_runner_instanceprofile"
  role = aws_iam_role.aws_github_runner_role.name
}

resource "aws_iam_role_policy_attachment" "admin_role_attach" {
  role       = aws_iam_role.aws_github_runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_policy" "aws_github_runners_policy" {
  name        = "aws_github_runner-Policy"
  description = "IAM Policy for aws_github_runner"
  policy      = file("${path.module}/../templates/iam/aws-github-runners/aws-github-runners.json")
}

resource "aws_iam_policy_attachment" "aws_github_runners_policy_Attachment" {
  name       = "aws_github_runner Policy Attachment"
  roles      = [aws_iam_role.aws_github_runner_role.name]
  policy_arn = aws_iam_policy.aws_github_runners_policy.arn
}

resource "aws_instance" "aws_github_runner_ami" {
  ami                         = var.amis["AmazonLinux2"]
  instance_type               = "t3.medium"
  disable_api_termination     = false
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.aws_github_runner_instanceprofile.id
  key_name                    = "aws_github_runner"
  subnet_id                   = "subnet-093c97f22e6ce21fe"
  vpc_security_group_ids      = [aws_security_group.aws_github_runners_securitygroup.id]
  tags = {
    Name    = "AWS Github Runner"
    Account = var.account
  }
  volume_tags = {
    Name    = "AWS Github Runner"
    Account = var.account
  }
  connection {
    host        = self.public_ip
    private_key = file("../resources/aws-github-runners/keys/id_rsa")
    user        = "ec2-user"
    type        = "ssh"
  }
  provisioner "local-exec" {
    command = "chmod 400 ../resources/aws-github-runners/keys/id_rsa && dos2unix scripts/aws_github_runner_setup.sh"
  }

  provisioner "file" {
    source      = "scripts/aws_github_runner_setup.sh"
    destination = "/tmp/aws_github_runner_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/aws_github_runner_setup.sh",
      "sudo /bin/bash -e /tmp/aws_github_runner_setup.sh"
    ]
  }

  root_block_device {
    volume_size           = "30"
    volume_type           = "gp3"
    encrypted             = "true"
    delete_on_termination = "true"
  }
}