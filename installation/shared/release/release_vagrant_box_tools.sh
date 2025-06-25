#!/usr/bin/env bash
set -e

# Update and reinstall essential packages
sudo apt update
sudo apt install -o DPkg::Options::=--force-confold -y -q --reinstall \
    bzip2 ca-certificates g++ gcc make gfortran git gzip lsb-release \
    patch python3 python3-pip tar unzip xz-utils zstd gnupg2 vim curl rsync

# Install VirtualBox 7.1.6
echo "Installing VirtualBox..."
# Download VirtualBox .deb
curl -O https://download.virtualbox.org/virtualbox/7.1.6/virtualbox-7.1_7.1.6-167084~Ubuntu~noble_amd64.deb

# Install the .deb package
sudo dpkg -i virtualbox-7.1_7.1.6-167084~Ubuntu~noble_amd64.deb || true
# Fix broken dependencies if any
sudo apt-get install -f -y
# Install build tools and kernel headers
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
# Configure VirtualBox kernel modules
sudo /sbin/vboxconfig

# Install Vagrant
echo "Installing Vagrant..."
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant

# Output version to verify install
echo "VirtualBox version:"
vboxmanage --version
echo "Vagrant version:"
vagrant --version

cd ./shared/release/VM_release
vagrant up

