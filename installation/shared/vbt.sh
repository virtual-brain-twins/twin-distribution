#!/usr/bin/env bash
set -e

start_time=$(date +%s)
cd $2 || exit

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot determine OS. /etc/os-release is missing."
    exit 1
fi

echo "Installing dependencies"
if [[ "$ID" == "rocky" || "$ID_LIKE" == *"rhel"* ]]; then
    echo "Rocky 9"
    module load Stages/2025
    module load GCC
    module load Python
elif [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
    echo "Ubuntu 24.04"
    chmod +x ./shared/commons/bootstrap.sh
    bash ./shared/commons/bootstrap.sh
    echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant
    chmod 0440 /etc/sudoers.d/vagrant
else
    echo "Unsupported OS"
    exit 1
fi

python3 -m venv --system-site-packages ./dedal_env
source ./dedal_env/bin/activate
python3 -m pip install --upgrade setuptools

gcc --version

# The custom Linux distribution designed for the VBT is fully configured with all modifications from bootstrap.sh applied.
git clone -b VT-109-HPC https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/dedal.git
cd ./dedal || exit
pip install .

cd ../shared || exit
python3 "$1"

chmod +x ./create_vbt_kernel.sh

end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Total runtime: $runtime seconds"

