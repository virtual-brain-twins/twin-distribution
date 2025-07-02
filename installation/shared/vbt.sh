#!/usr/bin/env bash
set -e

start_time=$(date +%s)
cd $2 || exit

chmod +x ./shared/commons/bootstrap.sh
bash ./shared/commons/bootstrap.sh

MINICONDA_DIR="/opt/conda"
ENV_NAME="dedal_env"

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot determine OS. /etc/os-release is missing."
    exit 1
fi

echo "Installing dependencies"
if [[ "$ID" == "rocky" || "$ID_LIKE" == *"rhel"* ]]; then
    echo "Rocky 9"
    dnf install -y wget bzip2
elif [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
    echo "Ubuntu 24.04"
    apt-get update -qq
    apt-get install -y -qq wget bzip2
else
    echo "Unsupported OS"
    exit 1
fi

echo "Downloading and installing Miniconda"
wget https://github.com/conda-forge/miniforge/releases/download/25.3.0-3/Miniforge3-25.3.0-3-Linux-x86_64.sh -O /tmp/miniconda.sh

echo "Installing Miniconda to $MINICONDA_DIR"
file /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p "$MINICONDA_DIR" || { echo "Miniconda install failed"; exit 1; }
rm -f /tmp/miniconda.sh

echo "Init conda."
source "$MINICONDA_DIR/etc/profile.d/conda.sh"

echo "Creating Python 3.12 environment: $ENV_NAME"
conda create -n "$ENV_NAME" python=3.12

echo "Activating environment and upgrading setuptools"
conda activate "$ENV_NAME"

python -m pip install --upgrade pip setuptools

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

