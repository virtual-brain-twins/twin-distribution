#!/usr/bin/env bash

SPACK_VERSION_EBRAINS=v0.22.0

# Ubuntu Essentials
init() {
  HOME_PATH=/home/vagrant
  echo "export HOME_PATH=/home/vagrant" >> /home/vagrant/.bashrc
  sudo apt update
  sudo apt install -y build-essential ca-certificates coreutils curl environment-modules gfortran git gpg lsb-release python3 python3-distutils python3-venv unzip zip moreutils dos2unix
  echo "export PATH=$PATH:$HOME_PATH/.local/bin" >> $HOME_PATH/.profile
  source $HOME_PATH/.profile
  sudo timedatectl set-timezone Europe/Bucharest
  sudo apt install jq --yes

  sudo apt install python3-pip
  pip install oras
}

spack_install() {
  # Spack installation according to the official documentation.
  echo 'Installing Spack'
  git clone -c feature.manyFiles=true --depth=2 --branch $SPACK_VERSION_EBRAINS https://github.com/spack/spack.git

  echo "Cloned spack"
  . spack/share/spack/setup-env.sh

  # Grant the user permission to make changes via Spack
  echo "export PATH=\"${HOME_PATH}/spack/bin:\$PATH\"" >> $HOME_PATH/.bashrc
  echo "source $HOME_PATH/spack/share/spack/setup-env.sh" >> $HOME_PATH/.bashrc
  echo "source $HOME_PATH/spack/share/spack/setup-env.sh" >> /home/vagrant/.profile
  sudo chown -R $USER:$USER $HOME_PATH/spack/

  source /home/vagrant/.bashrc
  echo 'Spack installed'

  spack --version
}

oras_install(){
  VERSION="1.2.1"
  curl -LO "https://github.com/oras-project/oras/releases/download/v${VERSION}/oras_${VERSION}_linux_amd64.tar.gz"
  mkdir -p oras-install/
  tar -zxf oras_${VERSION}_*.tar.gz -C oras-install/
  sudo mv oras-install/oras /usr/local/bin/
  rm -rf oras_${VERSION}_*.tar.gz oras-install/
}
