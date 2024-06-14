#!/usr/bin/env bash

echo "Debug: bootstrap.sh executed"


init() {
	sudo apt update --yes #&& sudo apt install vim --yes
	# TODO: Why the Vim install?
}

install_git() {
    sudo add-apt-repository ppa:git-core/ppa --yes
	sudo apt-get install git --yes
	#TODO: Why the strange repo for getting git?
}

install_python() {
	version=$1
	sudo apt install python3.9
	# sudo apt-get install build-essential --yes
	# sudo apt install -y make
    # sudo apt-get install -y libssl-dev openssl
	
	# #This feels strange: why not use apt to install python?
    # wget https://www.python.org/ftp/python/$version/Python-$version.tgz
    # tar xzvf Python-$version.tgz
    # cd Python-$version
    # ./configure
    # make
    # sudo make install
}



install_spack(){
    # Apparently I need to go to this directory first?
	cd  /home/vagrant
	#https://spack-tutorial.readthedocs.io/en/latest/tutorial_basics.html
	git clone --depth=100 --branch=releases/v0.22 https://github.com/spack/spack.git ~/spack
	
	# add to path
	#. spack/share/spack/setup-env.sh
}

init
install_git
install_spack

echo "Debug: bootstrap.sh executed completely"
