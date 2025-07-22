#!/usr/bin/env bash
set -e

apt update && apt install -y --no-install-recommends \
    bzip2 ca-certificates g++ gcc make gfortran git gzip patch lsb-release\
    python3 python3-pip tar unzip xz-utils zstd gnupg2 curl rsync jq \
    bison libgmp-dev libmpfr-dev libmpc-dev texinfo libisl-dev libzstd-dev  \
    gpg gpg-agent file python3.12-venv dos2unix