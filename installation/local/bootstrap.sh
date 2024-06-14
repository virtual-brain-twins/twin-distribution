#!/usr/bin/env bash

echo "Debug: bootstrap.sh started"

init() {
	sudo apt update --yes #&& sudo apt install vim --yes
	# TODO: Why the Vim install?
}

install_git() {
    sudo add-apt-repository ppa:git-core/ppa --yes
	sudo apt-get install git --yes
	#TODO: Why the strange repo for getting git?
}

install_spack(){
    # Apparently I need to go to this directory first?
	cd  /home/vagrant
	#https://spack-tutorial.readthedocs.io/en/latest/tutorial_basics.html
	git clone --depth=100 --branch=releases/v0.22 https://github.com/spack/spack.git ~/spack
	
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
