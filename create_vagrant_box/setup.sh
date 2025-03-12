#!/bin/bash

# Update package list
sudo apt-get update

# Install OpenSSH (SSH server) 
sudo apt-get install -y openssh-server

# Install Docker - added only for testing
sudo apt-get install -y docker.io
sudo usermod -aG docker vagrant   # Add vagrant user to the docker group

# Enable and start services
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl enable docker
sudo systemctl start docker

# Configure Vagrant SSH access (install insecure public key)
sudo mkdir -p /home/vagrant/.ssh
sudo sh -c "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVrkz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' > /home/vagrant/.ssh/authorized_keys"
sudo chmod 700 /home/vagrant/.ssh
sudo chmod 600 /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant/.ssh

# Clean up apt cache to reduce image size
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
