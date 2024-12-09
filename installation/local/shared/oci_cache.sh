#!/usr/bin/env bash

URL="https://docker-registry.ebrains.eu/api/v2.0"
PROJECT_ID=twin-spack-cache

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
  cd /home/vagrant/shared || exit
  # Clone the ebrains-spack-builds and twin-spack-env repositories
  git clone https://gitlab.ebrains.eu/adrianciu/twin-spack-env.git
  git clone --branch master https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/ebrains-spack-builds.git
  # Adding permissions to those repositories
  sudo chown -R vagrant_user:vagrant_user ./twin-spack-env/
  sudo chown -R vagrant_user:vagrant_user ./ebrains-spack-builds/

  spack env activate -p twin-spack-env
  delete_all_registries
  echo 'Deleted old caching'
  # Installing all libraries in order to generate the build caching
  spack mirror add --autopush local_cache ./local_cache
  # Adding the mirror to auto-push the build caches to a local directory after a package is installed
  spack install -v --fresh 2>log_error.txt | ts
  echo 'Installed fresh all packages'
  # spack mirror add twin_spack_cache_registry oci://docker-registry.ebrains.eu/twin-spack-cache/cache:latest --oci-username=$REGISTRY_USERNAME --oci-password=$REGISTRY_PASSWORD
  # Push the buildcache stored in the local directory to the OCI registry
  spack buildcache push -u -d ./local_cache  oci://docker-registry.ebrains.eu/twin-spack-cache/cache:latest --oci-username=$REGISTRY_USERNAME --oci-password=$REGISTRY_PASSWORD
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

start_time=$(date +%s)
cd /home/vagrant || exit
source ./shared/commons/bootstrap.sh
init
spack_install
source ~/.bashrc
cache_generate

echo "Debug: bootstrap.sh executed completely"
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Total runtime: $runtime seconds"