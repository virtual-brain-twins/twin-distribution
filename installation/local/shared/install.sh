#!/usr/bin/env bash

echo "Debug: bootstrap.sh started"

setup_spack_env(){
  cd $HOME_PATH/shared || exit
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
  spack repo add ebrains-spack-builds
  # Ensures that the permissions to ebrains-spack-builds and twin-spack-env persist each time the VM is started
  echo "sudo chown -R \$USER:\$USER $HOME_PATH/shared/ebrains-spack-builds/" >> $HOME_PATH/.bashrc
  echo "sudo chown -R \$USER:\$USER $HOME_PATH/shared/twin-spack-env/" >> $HOME_PATH/.bashrc
  echo "sudo chown -R \$USER:\$USER $HOME_PATH/spack" >> $HOME_PATH/.bashrc
  # When vagrant starts, twin-spack-env is activated
  echo "spack env activate -p $HOME_PATH/shared/twin-spack-env" >> $HOME_PATH/.bashrc

  # Install from buildcache the libraries
  spack mirror add twin_spack_cache $HOME_PATH/shared/local_cache
  spack install --no-check-signature 2> >(ts > log_install.txt)
  spack mirror rm twin_spack_cache
  # Clean up
  rm -rf $HOME_PATH/shared/local_cache
  source ./commons/utils.sh
  delete_if_empty "log_install.txt"
  delete_if_empty "log_oras.txt"
}


main(){
  start_time=$(date +%s)

  cd /home/vagrant || exit
  source ./shared/commons/bootstrap.sh
  source ./shared/commons/manage_build_cache.sh
  init
  source $HOME_PATH/.bashrc
  oras_install
  spack_install
  source $HOME_PATH/.bashrc
  registry_download_build_cache
  setup_spack_env

  end_time=$(date +%s)
  runtime=$((end_time - start_time))
  echo "Total runtime: $runtime seconds"
}

main