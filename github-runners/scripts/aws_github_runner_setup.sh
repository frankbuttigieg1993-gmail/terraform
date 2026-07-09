#!/bin/bash -e

# Installing Common Tools
echo "[+] Installing Common Tools"
sudo yum install -y curl wget unzip sshpass jq vim lsb-release git
sudo yum update -y

# Installing Docker
echo "[+] Installing Docker"
sudo yum install -y yum-utils
sudo amazon-linux-extras install -y docker
sudo yum install -y docker git libicu
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on

# # Installing Kubectl

# cat <<EOF > /etc/yum.repos.d/kubernetes.repo
# [kubernetes]
# name=Kubernetes
# baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
# enabled=1
# gpgcheck=0
# repo_gpgcheck=0
# gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
# EOF
# yum install -y kubectl

# Installing AWS CLI
echo "[+] Installing AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install OpenJDK 11
# sudo yum install java-1.8.0-openjdk-devel -y
sudo amazon-linux-extras install java-openjdk11 -y
java -version

# This setup script assumes that any project that uses Ansible, Gradle or builds with Java 8 or 11 will use docker images in the pipeline
# See the VHA project for examples
