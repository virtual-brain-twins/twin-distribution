#!/usr/bin/env bash

echo "Debug: bootstrap.sh started"

init() {
	sudo apt update
  sudo apt install build-essential ca-certificates coreutils curl environment-modules gfortran git gpg lsb-release python3 python3-distutils python3-venv unzip zip
}

install_git() {
#  sudo add-apt-repository ppa:git-core/ppa --yes
	sudo apt-get install git --yes
	#TODO: Why the strange repo for getting git?
	echo "Git installed"
}

install_jupyterlab(){
  echo "Jupyterlab 4 installed"
}

install_spack(){
  # Apparently I need to go to this directory first?
	cd  /home/vagrant
	#https://spack-tutorial.readthedocs.io/en/latest/tutorial_basics.html
	# git clone --depth=100 --branch=releases/v0.22 https://github.com/spack/spack.git ~/spack
	git clone --depth 1 -c advice.detachedHead=false -c feature.manyFiles=true --branch v0.20.0 https://github.com/spack/spack
	echo "Cloned spack"
	cd ~/pack
  . share/spack/setup-env.sh
  # spack repo add ebrains-spack-builds
  spack env create -d ebrains-spack-builds/
  echo "Created spack env"
#  export SYSTEMNAME=<your-system-name>
#  mkdir ebrains-spack-builds/site-config/$SYSTEMNAME
#  spack env activate ebrains-spack-builds
#  spack install --fresh

  # copy any site-specific .yaml files inside the new dir

	# add to path
	#. spack/share/spack/setup-env.sh
}

# Make sure we are in the correct path
cd /home/vagrant

init
install_git
install_spack

#git clone --branch ebrains-24-04 https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/ebrains-spack-builds.git

echo "Debug: bootstrap.sh executed completely"
