#!/bin/bash

export KERNEL_VERSION="3.1"
export KERNEL_NAME="vbt_kernel_${KERNEL_VERSION}"
export KERNEL_VENVS_DIR=${PROJECT_vbt}/vbt/jupyter/kernels
# set the kernel directory
export KERNEL_SPECS_PREFIX=${PROJECT_vbt}/.local

if [ ! -d "$KERNEL_SPECS_PREFIX" ]; then
  echo "ERROR: please create directory $KERNEL_SPECS_PREFIX"
fi
export KERNEL_SPECS_DIR=${KERNEL_SPECS_PREFIX}/share/jupyter/kernels

# check if kernel name is unique
if [ -d "${KERNEL_SPECS_DIR}/${KERNEL_NAME}" ]; then
  echo "ERROR: Kernel already exists in ${KERNEL_SPECS_DIR}/${KERNEL_NAME}"
  echo "       Rename kernel name or remove directory."
fi

echo $KERNEL_SPECS_DIR

# 1. Create the kernel
export VIRTUAL_ENV=${KERNEL_VENVS_DIR}/${KERNEL_NAME}
if [ -d "${VIRTUAL_ENV}" ]; then
  echo "ERROR: Directory for virtual environment already ${VIRTUAL_ENV}"
  echo
fi

# 1.1 - Load basic Python module
module -q purge
module -q load Stages/2025
module -q load GCC
module -q load Python


# 2. Copy launch script for the Jupyter Kernel

chmod +x ./kernel.sh
# source ./kernel.sh
# 3. Create Jupyter kernel configuration

# 3.1 - Create Jupyter kernel configuration directory and files
echo $VIRTUAL_ENV
python -m ipykernel install --name=${KERNEL_NAME} --prefix ${VIRTUAL_ENV}
export VIRTUAL_ENV_KERNELS=${VIRTUAL_ENV}/share/jupyter/kernels

echo $VIRTUAL_ENV_KERNELS

# # 3.2 - Adjust kernel.json file
# mv ${VIRTUAL_ENV_KERNELS}/${KERNEL_NAME}/kernel.json ${VIRTUAL_ENV_KERNELS}/${KERNEL_NAME}/kernel.json.orig

# cat > "${VIRTUAL_ENV_KERNELS}/${KERNEL_NAME}/kernel.json" <<EOF
# {
#  "argv": [
#   "'${KERNEL_VENVS_DIR}/${KERNEL_NAME}/kernel.sh",
#   "-m",
#   "ipykernel_launcher",
#   "-f",
#   "{connection_file}"
#  ],
#  "display_name": "vbt-spack-kernel",
#  "language": "python"
# }
# EOF

# cat ${VIRTUAL_ENV_KERNELS}/${KERNEL_NAME}/kernel.json

# # 3.3 - Create link to kernel specs

# cd ${KERNEL_SPECS_DIR} || exit
# ln -s ${VIRTUAL_ENV_KERNELS}/${KERNEL_NAME} .

# echo -e "\n\nThe new kernel '${KERNEL_NAME}' was added to your kernels in '${KERNEL_SPECS_DIR}/'\n"
# ls ${KERNEL_SPECS_DIR} # double check