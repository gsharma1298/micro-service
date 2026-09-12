#!/bin/bash
set -euxo pipefail

# ============================================================
# Ubuntu DevOps Tools Installation - EC2 User Data
# ============================================================

export DEBIAN_FRONTEND=noninteractive

# ============================================================
# 1. Update System
# ============================================================

apt-get update -y
apt-get upgrade -y

apt-get install -y \
  ca-certificates \
  curl \
  wget \
  gnupg \
  gnupg2 \
  software-properties-common \
  apt-transport-https \
  lsb-release \
  unzip \
  jq

# ============================================================
# 2. Install Git
# ============================================================

apt-get install -y git

# ============================================================
# 3. Install Java 21
# ============================================================

apt-get install -y openjdk-21-jdk

# ============================================================
# 4. Install Jenkins
# ============================================================

wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list

apt-get update -y
apt-get install -y jenkins

systemctl enable --now jenkins

# ============================================================
# 5. Install Terraform
# ============================================================

wget -O- https://apt.releases.hashicorp.com/gpg \
  | gpg --dearmor \
  | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/hashicorp.list

apt-get update -y
apt-get install -y terraform

# ============================================================
# 6. Install Maven
# ============================================================

apt-get install -y maven

# ============================================================
# 7. Install kubectl
# ============================================================

KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"

curl -LO \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm -f kubectl

# ============================================================
# 8. Install eksctl
# ============================================================

curl --silent --location \
  "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" \
  | tar xz -C /tmp

install -m 0755 /tmp/eksctl /usr/local/bin/eksctl

rm -f /tmp/eksctl

# ============================================================
# 9. Install Helm
# ============================================================

curl -fsSL \
  https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
  | bash

# ============================================================
# 10. Install Docker
# ============================================================

apt-get install -y docker.io

systemctl enable --now docker

# Add Ubuntu user to Docker group
if id ubuntu >/dev/null 2>&1; then
  usermod -aG docker ubuntu
fi

# Add Jenkins user to Docker group
if id jenkins >/dev/null 2>&1; then
  usermod -aG docker jenkins
fi

# ============================================================
# 11. Install Trivy
# ============================================================

wget -qO - \
  https://aquasecurity.github.io/trivy-repo/deb/public.key \
  | gpg --dearmor \
  | tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb \
$(lsb_release -sc) main" \
  > /etc/apt/sources.list.d/trivy.list

apt-get update -y
apt-get install -y trivy

# ============================================================
# 12. Install AWS CLI v2
# ============================================================

cd /tmp

curl -fsSL \
  "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o awscliv2.zip

unzip -q awscliv2.zip

if command -v aws >/dev/null 2>&1; then
  ./aws/install --update
else
  ./aws/install
fi

rm -rf /tmp/aws /tmp/awscliv2.zip

# ============================================================
# 13. Verify Installed Tools
# ============================================================

mkdir -p /var/log/devops-installation

{
  echo "===== DevOps Tools Installation Completed ====="
  date

  echo ""
  echo "Git:"
  git --version

  echo ""
  echo "Java:"
  java -version 2>&1

  echo ""
  echo "Jenkins:"
  jenkins --version

  echo ""
  echo "Terraform:"
  terraform version

  echo ""
  echo "Maven:"
  mvn -v

  echo ""
  echo "kubectl:"
  kubectl version --client

  echo ""
  echo "eksctl:"
  eksctl version

  echo ""
  echo "Helm:"
  helm version

  echo ""
  echo "Docker:"
  docker --version

  echo ""
  echo "Trivy:"
  trivy --version

  echo ""
  echo "AWS CLI:"
  aws --version

} > /var/log/devops-installation/versions.txt 2>&1

# ============================================================
# 14. Installation Complete
# ============================================================

echo "=============================================="
echo "DevOps Tools Installation Completed Successfully"
echo "=============================================="
