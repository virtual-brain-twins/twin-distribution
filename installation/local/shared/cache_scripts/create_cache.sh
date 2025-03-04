main(){
  start_time=$(date +%s)

  cd /home/vagrant/ || exit
  source ./shared/commons/bootstrap.sh
  init
  git clone -b dev https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/dedal.git
  cd ./dedal || exit
  pip install . --break-system-packages
  cd ../shared/cache_scripts || exit
  python3 create_cache.py

  end_time=$(date +%s)
  runtime=$((end_time - start_time))
  echo "Total runtime: $runtime seconds"
}

main
