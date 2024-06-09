#!/bin/bash

install_python() {
	version=$1
	sudo apt update
	sudo apt-get install build-essential --yes
	sudo apt install -y make
    sudo apt-get install -y libssl-dev openssl
    wget https://www.python.org/ftp/python/$version/Python-$version.tgz
    tar xzvf Python-$version.tgz
    cd Python-$version
    ./configure
    make
    sudo make install
}

install_pip() {
	echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe" | sudo tee /etc/apt/sources.list.d/universe.list
	sudo apt-get update
	sudo apt-get install -y python3-pip
}

install_git() {
    sudo add-apt-repository ppa:git-core/ppa --yes
	sudo apt-get update --yes
	sudo apt-get install git --yes
}

install_docker() {
    sudo apt-get update --yes
    sudo apt-get install ca-certificates curl --yes
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    sudo apt-get update --yes
    sudo apt-get install ca-certificates curl --yes
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update --yes
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --yes
}

install_conda_env() {
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

    install_jupyterlab3
    install_datalad
    install_nest_desktop 3.3.0
    install_tvb_web

    echo 'source /home/vagrant/miniconda3/bin/deactivate' >> /home/vagrant/.bashrc
    echo 'source /home/vagrant/miniconda3/bin/activate twin_brains_env' >> /home/vagrant/.bashrc
}

init() {
	sudo apt update && sudo apt install vim --yes
}

install_jupyterlab3() {
	conda install -c conda-forge jupyterlab="3.*" -y
}

install_datalad() {
    sudo apt install datalad --yes
}

install_nest_desktop() {
    version=$1
    pip install nest-desktop==$version 
}

install_tvb_web() {
	pip3 install tvb-library
    pip3 install tvb-framework
}


init
# install_python 3.11.8
install_pip
install_git
install_docker
install_conda_env 3.10
