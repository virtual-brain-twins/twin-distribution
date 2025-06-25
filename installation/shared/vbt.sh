#!/usr/bin/env bash
set -e

start_time=$(date +%s)
cd $2 || exit

chmod +x ./shared/commons/bootstrap.sh
bash ./shared/commons/bootstrap.sh

gcc --version

# The custom Linux distribution designed for the VBT is fully configured with all modifications from bootstrap.sh applied.
git clone -b VT-109-HPC https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/dedal.git
cd ./dedal || exit
pip install . --break-system-packages

cd ../shared || exit
python3 "$1"

end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Total runtime: $runtime seconds"

