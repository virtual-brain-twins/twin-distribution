#!/usr/bin/env bash

echo "Debug: bootstrap.sh started"

setup_spack_env(){
  cd /home/vagrant/shared || exit
  # Clone the ebrains-spack-builds and twin-spack-env repositories
  git clone https://gitlab.ebrains.eu/adrianciu/twin-spack-env.git
  git clone --branch master https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/ebrains-spack-builds.git
  export SYSTEMNAME='Twin_Brains'
  echo 'export SYSTEMNAME="Twin_Brains"' >> /etc/profile.d/vagrant_env.sh

  mkdir ./ebrains-spack-builds/site-config/$SYSTEMNAME
  mkdir ./twin-spack-env/site-config
  mkdir ./twin-spack-env/site-config/$SYSTEMNAME

  # Adding permissions to those repositories
  sudo chown -R $USER:$USER ./twin-spack-env/
  sudo chown -R $USER:$USER ./ebrains-spack-builds/

  spack env activate -p twin-spack-env
  # Install from buildcache the libraries
  spack mirror add twin_spack_cache_registry oci://docker-registry.ebrains.eu/twin-spack-cache/cache:latest --oci-username=$REGISTRY_USERNAME --oci-password=$REGISTRY_PASSWORD
  spack install --no-check-signature

  # Clean up
  spack clean -a

  # Ensures that the permissions to ebrains-spack-builds and twin-spack-env persist each time the VM is started
  echo 'sudo chown -R $USER:$USER /home/vagrant/shared/ebrains-spack-builds/' >> /home/vagrant/.bashrc
  echo 'sudo chown -R $USER:$USER /home/vagrant/shared/twin-spack-env/' >> /home/vagrant/.bashrc
  echo 'sudo chown -R $USER:$USER /home/vagrant/spack' >> /home/vagrant/.bashrc
  # When vagrant starts, twin-spack-env is activated
  echo 'spack env activate -p /home/vagrant/shared/twin-spack-env' >> /home/vagrant/.bashrc
}

start_time=$(date +%s)
cd /home/vagrant || exit
source ./shared/commons/bootstrap.sh
init
spack_install
setup_spack_env

echo "Debug: bootstrap.sh executed completely"
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Total runtime: $runtime seconds"