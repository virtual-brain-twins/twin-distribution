URL="https://docker-registry.ebrains.eu/api/v2.0"
PROJECT_ID=twin-spack-cache

# Essential for ubuntu
init() {
	sudo apt update
  sudo apt install -y build-essential ca-certificates coreutils curl environment-modules gfortran git gpg lsb-release python3 python3-distutils python3-venv unzip zip
  echo 'export PATH=$PATH:/home/vagrant/.local/bin' >> /home/vagrant/.profile
  source /home/vagrant/.profile
  sudo timedatectl set-timezone Europe/Bucharest
  sudo apt install jq --yes
}

install_spack() {
  # Spack installation according to the official documentation.
  echo 'Spack install'
  git clone --depth 1 -c advice.detachedHead=false -c feature.manyFiles=true --branch v0.21.1 https://github.com/spack/spack

  echo "Cloned spack"
  . spack/share/spack/setup-env.sh
  echo 'export PATH="/home/vagrant/spack/bin:$PATH"' >> /home/vagrant/.bashrc
  echo 'source /home/vagrant/spack/share/spack/setup-env.sh' >> /home/vagrant/.bashrc

  sudo chown -R $USER:$USER /home/vagrant/spack/
  echo "Install spack"
  spack --version
  source /home/vagrant/.bashrc
}

# This function is used to retrieve the ids of the container registries inside a repo and delete them all
delete_all_registries() {
  # GET in a list all the container registries ids
  REGISTRY_REPOS=$(curl --silent --header "PRIVATE-TOKEN: $REGISTRY_ACCESS_TOKEN" "$URL/projects/$PROJECT_ID/repositories" | jq -r '.[].id')
  # Delete each container registry
  for REPO_ID in $REGISTRY_REPOS; do
      echo "Deleting container registry repository ID: $REPO_ID"
      curl --silent --request DELETE --header "PRIVATE-TOKEN: $REGISTRY_ACCESS_TOKEN" "$URL/projects/$PROJECT_ID/repositories/$REPO_ID"
  done
}

cache_generate() {
  cd /home/vagrant/shared || exit
  # Clone the ebrains-spack-builds and twin-spack-env repositories
  git clone https://$SPACK_ENV_TOKEN@gitlab.ebrains.eu/adrianciu/twin-spack-env.git
  git clone --branch master https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/ebrains-spack-builds.git
  # Adding permissions to those repositories
  sudo chown -R $USER:$USER ./twin-spack-env/
  sudo chown -R $USER:$USER ./ebrains-spack-builds/

  spack env activate -p twin-spack-env
  delete_all_registries
  echo 'Deleted old caching'
  # Installing all libraries in order to generate the build caching
  spack install --fresh
  echo 'Installed fresh all packages'
  # Adding the mirror to push the build caches
  spack buildcache push -u twin_spack_cache_registry
  status_code=$?
  spack env deactivate

  if [ $status_code -ne 0 ]; then
    echo "Status code: $status_code"
    echo "Something went wrong when pushing the build cache to oci registry!"
  else
    echo "clean up"
    rm -rf ebrains-spack-builds
    rm -rf twin-spack-env
  fi

}

cd /home/vagrant || exit
init
install_spack
cache_generate