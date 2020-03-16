#!/bin/sh

INSTALL_DIR=/srv/workfromhome-with-inlets

# Update the apt package index
apt-get update

# Install packages to allow apt to use a repository over HTTPS
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    gnupg \
    lsb-release \
    software-properties-common \
    git \
    jq \
    unzip

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Use the following command to set up the stable repository.
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Update the apt package index.
apt-get update

# Install the latest version of Docker Engine - Community and containerd.
apt-get -y install docker-ce docker-ce-cli containerd.io 

# install docker-compose
curl -SLo /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-Linux-x86_64"
chown root:root /usr/local/bin/docker-compose
chmod 0755 /usr/local/bin/docker-compose

# Install terraform
curl -SLo terraform_0.12.23_linux_amd64.zip "https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_linux_amd64.zip"
unzip terraform_0.12.23_linux_amd64.zip
rm -f terraform_0.12.23_linux_amd64.zip
mv ./terraform /usr/local/bin/terraform

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install inlets
curl -sLS https://get.inlets.dev | sh

# Clone workfromhome-with-docker git repo
mkdir -p $INSTALL_DIR
git clone https://github.com/andif888/workfromhome-with-inlets.git $INSTALL_DIR

