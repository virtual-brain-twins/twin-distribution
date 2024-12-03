#!/usr/bin/env bash

echo "Debug: bootstrap.sh started"

init() {
	sudo apt update
  sudo apt install -y build-essential ca-certificates coreutils curl environment-modules gfortran git gpg lsb-release python3 python3-distutils python3-venv unzip zip
  echo 'export PATH=$PATH:/home/vagrant/.local/bin' >> /home/vagrant/.profile
  source /home/vagrant/.profile
  sudo timedatectl set-timezone Europe/Bucharest
  sudo apt install jq --yes
}

install_git() {
	sudo apt-get install git --yes
	echo "Git installed"
}

install_jupyterlab(){
  conda install -c conda-forge jupyterlab="4.*" -y
  echo "Jupyter lab 4 installed"
}

install_spack(){
  echo 'Spack install'
  git clone --depth 1 -c advice.detachedHead=false -c feature.manyFiles=true --branch v0.21.1 https://github.com/spack/spack

  echo "Cloned spack"
  . spack/share/spack/setup-env.sh
  echo 'export PATH="/home/vagrant/spack/bin:$PATH"' >> /home/vagrant/.bashrc
  echo 'source /home/vagrant/spack/share/spack/setup-env.sh' >> /home/vagrant/.bashrc
  source /home/vagrant/.bashrc

  sudo chown -R $USER:$USER /home/vagrant/spack/
  echo "Install spack"
  spack --version
}

setup_spack_env(){
  cd ~/shared
  # Adding the twin env and the ebrains spack repo from where the libraries are installed
  git clone https://vagrant-spack:glpat-f5GwpnvoZEiT8z3U55Jj@gitlab.ebrains.eu/adrianciu/twin-spack-env.git
  git clone --branch master https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/ebrains-spack-builds.git
  export SYSTEMNAME='Twin_Brains'
  echo 'export SYSTEMNAME="Twin_Brains"' >> /etc/profile.d/vagrant_env.sh

  mkdir ./ebrains-spack-builds/site-config/$SYSTEMNAME
  mkdir ./twin-spack-env/site-config
  mkdir ./twin-spack-env/site-config/$SYSTEMNAME

  sudo chown -R $USER:$USER /home/vagrant/spack
  sudo chown -R $USER:$USER /home/vagrant/shared/twin-spack-env/
  sudo chown -R $USER:$USER /home/vagrant/shared/ebrains-spack-builds/
  #echo 'spack repo list | grep -q ebrains-spack-builds || spack repo add ~/shared/ebrains-spack-builds' >> /home/vagrant/.bashrc
#  echo 'sudo chown -R $USER:$USER /home/vagrant/shared/ebrains-spack-builds/' >> /home/vagrant/.bashrc
#  echo 'sudo chown -R $USER:$USER /home/vagrant/shared/twin-spack-env/' >> /home/vagrant/.bashrc
  echo 'sudo chown -R $USER:$USER /home/vagrant/spack' >> /home/vagrant/.bashrc
  echo 'spack env activate -p --without-view ~/shared/twin-spack-env' >> /home/vagrant/.bashrc

  spack env activate -p twin-spack-env
  #spack install --no-check-signature
  # spack clean -a
}

install_miniconda(){
  version=$1
  set -e
  if [ -d "/home/vagrant/miniconda3" ]; then
      echo "Removing existing Miniconda installation at /home/vagrant/miniconda3"
      rm -rf /home/vagrant/miniconda3
  fi
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
  chmod +x miniconda.sh
  ./miniconda.sh -b -p /home/vagrant/miniconda3
  eval "$(/home/vagrant/miniconda3/bin/conda shell.bash hook)"
  rm miniconda.sh
  echo 'export PATH="/home/vagrant/miniconda3/bin:$PATH"' >> /home/vagrant/.bashrc
  source /home/vagrant/.bashrc

  if command -v conda &>/dev/null; then
      echo "Conda installed successfully"
      conda --version
  else
      echo "Conda installation failed"
      exit 1
  fi

  conda config --add channels conda-forge

  echo "Creating conda environment with Python version: $version"

  conda_create_command="/home/vagrant/miniconda3/bin/conda create --name twin_brains_env python=$version --yes"
  echo "Running command: $conda_create_command"
  eval $conda_create_command

  source /home/vagrant/miniconda3/bin/activate twin_brains_env

  if [ "$CONDA_DEFAULT_ENV" != "twin_brains_env" ]; then
      echo "Failed to activate the conda environment"
      exit 1
  fi

  installed_python_version=$(python --version)
  echo "Installed Python version in the environment: $installed_python_version"

  if [[ $installed_python_version != "Python $version"* ]]; then
      echo "Python version mismatch. Expected: $version, Found: $installed_python_version"
      exit 1
  fi

  echo 'source /home/vagrant/miniconda3/bin/deactivate' >> /home/vagrant/.bashrc
  echo 'source /home/vagrant/miniconda3/bin/activate twin_brains_env' >> /home/vagrant/.bashrc
}

install_tvb_ext() {
  pip install tvb-ext-bucket
  pip install tvb-ext-unicore
  pip install tvb-ext-xircuits
}

start_time=$(date +%s)
init
install_git
install_spack
setup_spack_env

echo "Debug: bootstrap.sh executed completely"
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Total runtime: $runtime seconds"