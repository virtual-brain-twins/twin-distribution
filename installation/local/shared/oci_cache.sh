#!/usr/bin/env bash

URL="https://docker-registry.ebrains.eu/api/v2.0"
PROJECT_ID=$REGISTRY_PROJECT

# This function is used to retrieve the ids of the container registries inside a repo and delete them all
delete_all_registries() {
  # GET in a list all the container registries ids
  REGISTRY_REPOS=$(curl --silent --header "PRIVATE-TOKEN: $REGISTRY_PASSWORD" "$URL/projects/$PROJECT_ID/repositories" | jq -r '.[].id')
  # Delete each container registry
  for REPO_ID in $REGISTRY_REPOS; do
      echo "Deleting container registry repository ID: $REPO_ID"
      curl --silent --request DELETE --header "PRIVATE-TOKEN: $REGISTRY_PASSWORD" "$URL/projects/$PROJECT_ID/repositories/$REPO_ID"
  done
}

cache_generate() {
  cd $HOME_PATH/shared || exit
  # Clone the ebrains-spack-builds and twin-spack-env repositories
  git clone https://gitlab.ebrains.eu/adrianciu/twin-spack-env.git
  git clone --branch master https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/ebrains-spack-builds.git
  # Adding permissions to those repositories
  sudo chown -R $USER:$USER ./twin-spack-env/
  sudo chown -R $USER:$USER ./ebrains-spack-builds/

  spack env activate -p twin-spack-env
  spack repo add ebrains-spack-builds
  # Installing all libraries in order to generate the build caching
  spack gpg init
  spack gpg create vbt science@codemart.ro
  mkdir $HOME_PATH/shared/local_cache
  spack mirror add local_cache $HOME_PATH/shared/local_cache
  # Adding the mirror to auto-push the build caches to a local directory after a package is installed
  spack install -v --fresh 2> >(ts > log_generate_cache.txt)
  echo 'Installed fresh all packages'
}


main(){
  start_time=$(date +%s)

  cd /home/vagrant || exit
  source ./shared/commons/bootstrap.sh
  source ./shared/commons/manage_build_cache.sh
  init
  source ~/.bashrc
  spack_install
  oras_install
  source ~/.bashrc
  cache_generate
  registry_upload_build_cache
  # Clean up the local buildcache folder
  rm -rf $HOME_PATH/shared/local_cache
  source ./shared/commons/utils.sh
  delete_if_empty "log_generate_cache.txt"
  delete_if_empty "log_oras.txt"

  end_time=$(date +%s)
  runtime=$((end_time - start_time))
  echo "Total runtime: $runtime seconds"
}

main

