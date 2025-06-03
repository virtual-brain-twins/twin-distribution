#!/usr/bin/env bash
set -e

apt update && apt install -y --no-install-recommends \
    bzip2 ca-certificates g++ gcc make gfortran git gzip patch \
    python3 python3-pip tar unzip xz-utils zstd gnupg2 curl rsync jq \
    flex bison libgmp-dev libmpfr-dev libmpc-dev texinfo libisl-dev libzstd-dev
apt install jq --yes
apt install python3-pip -y
python3 -m pip install --upgrade pip setuptools --break-system-packages
