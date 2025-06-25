set -e

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot determine OS. /etc/os-release is missing."
    exit 1
fi

if [[ "$ID" == "rocky" || "$ID_LIKE" == *"rhel"* ]]; then
  echo "Rocky 9"

  dnf groupinstall -y "Development Tools"
  dnf install -y \
      mpfr-devel gmp-devel libmpc-devel zlib-devel glibc-devel.i686 \
      glibc-devel wget gnupg2 tar xz

  wget https://ftp.gwdg.de/pub/misc/gcc/releases/gcc-13.3.0/gcc-13.3.0.tar.xz
  wget https://ftp.gwdg.de/pub/misc/gcc/releases/gcc-13.3.0/gcc-13.3.0.tar.xz.sig

  gpg --recv-keys 6C35B99309B5FA62
  gpg --verify gcc-13.3.0.tar.xz.sig gcc-13.3.0.tar.xz

  tar -xf gcc-13.3.0.tar.xz
  cd gcc-13.3.0

  ./contrib/download_prerequisites

  mkdir build && cd build

  ../configure --enable-languages=c,c++ \
      --disable-multilib \
      --prefix=/opt/gcc-13.3

  make -j"$(nproc)" > /tmp/gcc-build.log 2>&1
  make install > /tmp/gcc-install.log 2>&1

  # Set as default
  ln -sf /opt/gcc-13.3/bin/gcc /usr/bin/gcc
  ln -sf /opt/gcc-13.3/bin/g++ /usr/bin/g++

  dnf install -y python3 python3-pip
  python3 -m pip install --upgrade setuptools --break-system-packages

elif [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
    # Ubuntu 24.04
    echo "Ubuntu 24.04"
    apt update && apt install -y --no-install-recommends \
        bzip2 ca-certificates g++ gcc make gfortran git gzip patch lsb-release \
        python3 python3-pip tar unzip xz-utils zstd gnupg2 curl rsync jq \
        flex bison libgmp-dev libmpfr-dev libmpc-dev texinfo libisl-dev libzstd-dev \
        gnupg gpg gpg-agent file

    python3 -m pip install --upgrade setuptools --break-system-packages

else
    echo "Unsupported OS: $ID"
    exit 1
fi