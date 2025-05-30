#!/usr/bin/env bash
set -e

# Update and install required tools
apt-get update
apt-get install -o DPkg::Options::=--force-confold -y -q --reinstall \
    bzip2 ca-certificates g++ make gfortran git gzip lsb-release \
    patch python3 python3-pip tar unzip xz-utils zstd gnupg2 vim curl rsync wget build-essential flex libgmp-dev libmpc-dev libmpfr-dev texinfo

apt-get install -y jq
python3 -m pip install --upgrade pip setuptools wheel --break-system-packages

# Set GCC version
GCC_VERSION=13.3.0
GCC_DIR=gcc-${GCC_VERSION}
BUILD_DIR=/tmp/gcc-build

# Download and extract GCC source
cd /tmp
wget https://ftp.gnu.org/gnu/gcc/${GCC_DIR}/${GCC_DIR}.tar.xz
tar -xf ${GCC_DIR}.tar.xz
cd ${GCC_DIR}
./contrib/download_prerequisites

# Create a separate build directory
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

# Configure and build
../${GCC_DIR}/configure --disable-multilib --enable-languages=c,c++ --prefix=/usr/local/gcc-${GCC_VERSION}
make -j"$(nproc)"
make install

# Update PATH and alternatives
update-alternatives --install /usr/bin/gcc gcc /usr/local/gcc-${GCC_VERSION}/bin/gcc 100 \
                    --slave /usr/bin/g++ g++ /usr/local/gcc-${GCC_VERSION}/bin/g++
update-alternatives --config gcc

# Verify
gcc --version
