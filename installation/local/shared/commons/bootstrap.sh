#!/usr/bin/env bash
set -e

sed -i 's|http://archive.ubuntu.com|https://archive.ubuntu.com|g' /etc/apt/sources.list
sed -i 's|http://security.ubuntu.com|https://security.ubuntu.com|g' /etc/apt/sources.list
apt-get update
apt install -o DPkg::Options::=--force-confold -y -q --reinstall \
                  bzip2 ca-certificates g++ gcc make gfortran git gzip lsb-release \
                  patch python3 python3-pip tar unzip xz-utils zstd gnupg2 vim curl rsync
apt install jq --yes
apt install python3-pip -y
python3 -m pip install --upgrade pip setuptools wheel --break-system-packages
