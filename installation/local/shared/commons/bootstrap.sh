#!/usr/bin/env bash

#HOME_PATH=/home/vagrant
#mkdir -p $HOME_PATH
#echo "export HOME_PATH=/home/vagrant" >> /home/vagrant/.bashrc
apt update
apt install -o DPkg::Options::=--force-confold -y -q --reinstall \
                  bzip2 ca-certificates g++ gcc make gfortran git gzip lsb-release \
                  patch python3 python3-pip tar unzip xz-utils zstd gnupg2 vim curl rsync
#echo "export PATH=$PATH:$HOME_PATH/.local/bin" >> $HOME_PATH/.profile
#source $HOME_PATH/.profile
timedatectl set-timezone Europe/Bucharest
apt install jq --yes
apt install python3-pip -y
python3 -m pip install --upgrade pip setuptools wheel --break-system-packages
