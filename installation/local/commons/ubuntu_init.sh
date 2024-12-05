sudo apt update
sudo apt install -y build-essential ca-certificates coreutils curl environment-modules gfortran git gpg lsb-release python3 python3-distutils python3-venv unzip zip
echo 'export PATH=$PATH:/home/vagrant/.local/bin' >> /home/vagrant/.profile
source /home/vagrant/.profile
sudo timedatectl set-timezone Europe/Bucharest
sudo apt install jq --yes