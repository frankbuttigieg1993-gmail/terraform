output "instance_ip" {
  value = "${jsonencode(aws_instance.aws_github_runner_ami.private_ip)}"
}
