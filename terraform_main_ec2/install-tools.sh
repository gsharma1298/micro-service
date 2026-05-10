#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y git wget unzip curl software-properties-common gnupg lsb-release apt-transport-https ca-certificates

git --version

# Install Java 17
sudo apt install -y openjdk-17-jdk
java -version

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

node -v
npm -v

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install -y terraform

terraform -v

# Install Maven
sudo apt install -y maven
mvn -v

# Install Ansible
sudo apt install -y ansible
ansible --version

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/

kubectl version --client

# Install eksctl
curl --silent --location \
"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
| tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm version

# Install Docker
sudo apt install -y docker.io

sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins

sudo systemctl enable docker
sudo systemctl start docker

sudo chmod 777 /var/run/docker.sock

docker --version

# Install Docker Compose
sudo curl -L \
"https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose --version

# Run SonarQube using Docker
sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

sudo docker ps

# Install Trivy
wget https://github.com/aquasecurity/trivy/releases/download/v0.48.3/trivy_0.48.3_Linux-64bit.deb

sudo dpkg -i trivy_0.48.3_Linux-64bit.deb

trivy --version

# Install Vault
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install -y vault

vault --version

# Install MariaDB
sudo apt install -y mariadb-server

sudo systemctl enable mariadb
sudo systemctl start mariadb

mysql --version

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

sudo systemctl enable postgresql
sudo systemctl start postgresql

psql --version

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install

rm -rf aws awscliv2.zip

aws --version

echo "✅ Initialization script completed successfully."

# Install ArgoCD
kubectl create namespace argocd

kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl get pods -n argocd

# Install Prometheus and Grafana
helm repo add prometheus-community \
https://prometheus-community.github.io/helm-charts

helm repo update

kubectl create namespace prometheus

helm install prometheus \
prometheus-community/kube-prometheus-stack \
-n prometheus

kubectl get pods -n prometheus
