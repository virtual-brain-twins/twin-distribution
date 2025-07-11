#!/bin/bash

source /home/vagrant/spack/share/spack/setup-env.sh
spack env activate -p  /home/vagrant/data/vbt-spack-env

exec python -m ipykernel $@
