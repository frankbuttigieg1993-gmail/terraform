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
sudo nvm install --lts

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
sudo amazon-linux-extras enable java-openjdk11
sudo yum clean metadata
sudo yum install -y java-11-openjdk-devel unzip wget

# Install Gradle

cd /tmp
sudo mkdir /opt/gradle
sudo wget https://services.gradle.org/distributions/gradle-9.6.0-bin.zip
sudo unzip -d /opt/gradle gradle-9.6.0-bin.zip

sudo tee /etc/profile.d/gradle.sh << 'EOF'
export GRADLE_HOME=/opt/gradle/gradle-9.6.0
export PATH=$GRADLE_HOME/bin:$PATH
EOF

sudo chmod +x /etc/profile.d/gradle.sh
source /etc/profile.d/gradle.sh
gradle -v