#!/usr/bin/env bash

# Ubuntu Essentials
init() {
  sudo useradd -m -s /bin/bash vagrant_user
  echo "vagrant_user:vagrant_user" | sudo chpasswd
  sudo usermod -aG sudo vagrant_user
  sudo apt update
  sudo apt install -y build-essential ca-certificates coreutils curl environment-modules gfortran git gpg lsb-release python3 python3-distutils python3-venv unzip zip
  echo 'export PATH=$PATH:/home/vagrant/.local/bin' >> /home/vagrant/.profile
  source /home/vagrant/.profile
  sudo timedatectl set-timezone Europe/Bucharest
  sudo apt install jq --yes
}

spack_install() {
  # Spack installation according to the official documentation.
  echo 'Spack install'
  git clone -c feature.manyFiles=true --depth=2 https://github.com/spack/spack.git

  echo "Cloned spack"
  . spack/share/spack/setup-env.sh
  echo 'export PATH="/home/vagrant/spack/bin:$PATH"' >> /home/vagrant/.bashrc
  echo 'source /home/vagrant/spack/share/spack/setup-env.sh' >> /home/vagrant/.bashrc
  source /home/vagrant/.bashrc

  sudo chown -R $USER:$USER /home/vagrant/spack/
  echo "Install spack"
  spack --version
}
