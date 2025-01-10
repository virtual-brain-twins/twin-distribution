# VirtualBrainTwin

## Prerequisites

Before starting, make sure you have the following tools installed:

1. **VirtualBox** - version 7.0.20
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

You can directly download the VM to attach it to VirtualBox by importing it as an appliance. The username and password are both "vagrant".

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

In order to create the build cache on OCI Registry you have:
- find a suitable OCI Registry and save the host in the environmental variable $REGISTRY_HOST
- create a project on OCI Registry and save the project name in the environmental variable $REGISTRY_PROJECT
- create (if possible) a robot account which has access to the project and save its credentials in the environmental variables $REGISTRY_USERNAME and $REGISTRY_PASSWORD
- define a version of you build cache and save it in the environmental variable $REGISTRY_CACHE_VERSION

Those environmental variables will be provisioned by Vagrant into the VMs.

## Acknowledgments

This project has received funding from the European Union’s Research and Innovation Program Horizon Europe under Grant Agreement No. 101137289 (Virtual Brain Twin Project).