main(){
  start_time=$(date +%s)
  cd /home/vagrant/ || exit
  # The custom Linux distribution designed for the VBT is fully configured with all modifications from bootstrap.sh applied.
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
