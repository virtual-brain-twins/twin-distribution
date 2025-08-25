#!/bin/bash

#source /p/scratch/vbt/vbt-spack/vbt_spack_kernel/$KERNEL_VERSION/spack/share/spack/setup-env.sh
#spack env activate -p  /p/scratch/vbt/vbt-spack/vbt_spack_kernel/$KERNEL_VERSION/data/vbt-spack-env

source /p/scratch/vbt/vbt-spack/vbt_spack_kernel_job/ciu1/builds/virtualbraintwin_7400/000/virtualbraintwin/virtualbraintwin/installation/spack/share/spack/setup-env.sh
spack env activate -p  /p/scratch/vbt/vbt-spack/vbt_spack_kernel_job/ciu1/builds/virtualbraintwin_7400/000/virtualbraintwin/virtualbraintwin/installation/data/vbt-spack-env

exec python -m ipykernel $@
