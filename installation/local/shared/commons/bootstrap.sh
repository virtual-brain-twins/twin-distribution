#!/usr/bin/env bash


# Ubuntu Essentials
init() {
  HOME_PATH=/home/vagrant
  echo "export HOME_PATH=/home/vagrant" >> /home/vagrant/.bashrc
  sudo apt update
  sudo apt upgrade -y
  sudo apt install -y build-essential bzip2 ca-certificates binutils make g++ gcc gfortran git gzip lsb-release patch python3 python3-pip tar unzip xz-utils zstd moreutils dos2unix
  echo "export PATH=$PATH:$HOME_PATH/.local/bin" >> $HOME_PATH/.profile
  source $HOME_PATH/.profile
  timedatectl set-timezone Europe/Bucharest
  sudo apt install jq --yes
  sudo apt install python3-pip -y
  python3 -m pip install --upgrade pip setuptools wheel --break-system-packages
}
