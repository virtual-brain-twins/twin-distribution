#!/bin/bash

module load Stages/2025
module load GCC
module load Python

export KERNEL_VERSION="${KERNEL_VERSION}"

source ${SCRATCH_vbt}/vbt-spack/vbt_spack_kernel/${KERNEL_VERSION}/virtualbraintwin/installation/spack/share/spack/setup-env.sh
spack env activate -p ${SCRATCH_vbt}/vbt-spack/vbt_spack_kernel/${KERNEL_VERSION}/virtualbraintwin/installation/data/vbt-spack-env