# VirtualBrainTwin

## Prerequisites

Before starting, make sure you have the following tools installed:

1. **VirtualBox**
   - [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads)

2. **VirtualBox**
   - [Download Vagrant](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant)

3. **Vagrant Disksize Plugin**
    
    This plugin is used to custom configure the disk size allocated to the VM created with Vagrant.
   - [Download vagrant-disksize](https://github.com/sprotheroe/vagrant-disksize)

## User:

Hardware prerequisites allocated to the Ubuntu VM for the installation of the packages from the buildcache:

- CPU: 2
- RAM: 2 GB

Hardware prerequisites allocated to the Ubuntu VM for the installation of the packages:

- CPU: 10
- RAM: 16 GB

This hardware may vary depending on what package is installed in the spack environment.

## Developer:

Hardware prerequisites allocated to the Ubuntu VM:

- CPU: 10
- RAM: 16 GB

You can start the local build of spack packages that will be pushed to docker registry by running the following command in /installation/local/VM_buildcache:
- vagrant up

You can start the local installation by running the following command in /installation/local/VM:
- vagrant up

In order to connect to the newly created VM, you need to run the following command in /installation/local/VM:
- vagrant ssh

## Acknowledgments

This project has received funding from the European Union’s Research and Innovation Program Horizon Europe under Grant Agreement No. 101137289 (Virtual Brain Twin Project).