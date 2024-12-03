GITLAB_URL="https://gitlab.com"
GITLAB_REGISTRY_URL="oci://registry.gitlab.com/test_oci/oci"
ACCESS_TOKEN="glpat-mSdHJ5k89yes_m-EtHfv"

# Example query to get project repository ids:
# curl  --header "PRIVATE-TOKEN:<PAT>" "https://gitlab.com/api/v4/projects/<id>/"

PROJECT_ID=62235387
REPOSITORY_ID=6873045
NAMESPACE=test_oci
REPONAME="twin-spack-cache-oci"

#cd ../

init() {
	sudo apt update
  sudo apt install -y build-essential ca-certificates coreutils curl environment-modules gfortran git gpg lsb-release python3 python3-distutils python3-venv unzip zip
  echo 'export PATH=$PATH:/home/vagrant/.local/bin' >> /home/vagrant/.profile
  source /home/vagrant/.profile
  sudo timedatectl set-timezone Europe/Bucharest
  sudo apt install jq --yes
}

install_spack() {
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

cache_generate() {
  cd /home/vagrant/shared || exit

  git clone https://glpat-2jbDa6Wx48yZKeyW3BGZ@gitlab.ebrains.eu/adrianciu/twin-spack-env.git
  git clone --branch master https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/ebrains-spack-builds.git
  sudo chown -R $USER:$USER ./twin-spack-env/
  sudo chown -R $USER:$USER ./ebrains-spack-builds/
  spack env activate -p twin-spack-env
  spack repo rm ebrains-spack-builds
  spack repo add ebrains-spack-builds

  spack mirror rm twin_spack_cache_registry
  spack install --fresh
  echo 'Installed fresh all libraries'
  spack mirror add --oci-username $NAMESPACE --oci-password $ACCESS_TOKEN twin_spack_cache_registry oci://$GITLAB_REGISTRY_URL/$NAMESPACE/$REPONAME

  curl --silent --request DELETE --header "PRIVATE-TOKEN:$ACCESS_TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/registry/repositories/$REPOSITORY_ID"
  echo 'Deleted old caching'

  spack buildcache push -u oci://$GITLAB_REGISTRY_URL/$NAMESPACE/$REPONAME
  spack repo rm ebrains-spack-builds

  spack env deactivate twin-spack-env

  # cleanup
  cd ../../
  #rm -rf spack-update
  cd ../
  #rm -rf spack
}

cd /home/vagrant
init
install_spack
cache_generate