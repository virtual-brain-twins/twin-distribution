#!/bin/bash

export KERNEL_NAME="vbt_kernel_${KERNEL_VERSION}"
export KERNELS_DIR=${PROJECT_vbt}/vbt/jupyter/kernels
echo $KERNEL_NAME
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
export KERNEL_DIR=${KERNELS_DIR}/${KERNEL_NAME}
if [ -d "${KERNEL_DIR}" ]; then
  echo "ERROR: Directory for kernel ${KERNEL_NAME} already ${KERNEL_DIR}"
  exit 1
fi

# 1.1 - Load basic Python module
module -q purge
module -q load Stages/2025
module -q load GCC
module -q load Python

# 2. Create kernel.sh and launch the vbt-spack-env
cat > "./kernel.sh" <<EOF
#!/bin/bash

module load Stages/2025
module load GCC
module load Python

export KERNEL_VERSION="\${KERNEL_VERSION}"

source ${SCRATCH_vbt}/vbt-spack/vbt_spack_kernel/${KERNEL_VERSION}/virtualbraintwin/installation/spack/share/spack/setup-env.sh
spack env activate -p ${SCRATCH_vbt}/vbt-spack/vbt_spack_kernel/${KERNEL_VERSION}/virtualbraintwin/installation/data/vbt-spack-env

EOF

chmod +x "./kernel.sh"
source ./kernel.sh

# 3. Create Jupyter kernel configuration

# 3.1 - Create Jupyter kernel configuration directory and files
python -m ipykernel install --name=${KERNEL_NAME} --prefix ${KERNEL_DIR}
export GLOBAL_KERNELS_DIR=${KERNEL_DIR}/share/jupyter/kernels

# 3.2 - Adjust kernel.json file
mv ${GLOBAL_KERNELS_DIR}/${KERNEL_NAME}/kernel.json ${GLOBAL_KERNELS_DIR}/${KERNEL_NAME}/kernel.json.orig

# 3.3 - Copy kernel.sh
echo "exec python -m ipykernel \$@" >> "./kernel.sh"
cp "./kernel.sh" "${GLOBAL_KERNELS_DIR}/${KERNEL_NAME}/kernel.sh"
chmod +x "${GLOBAL_KERNELS_DIR}/${KERNEL_NAME}/kernel.sh"
cat "${GLOBAL_KERNELS_DIR}/${KERNEL_NAME}/kernel.sh"

# Create a custom kernel.json
cat > "${GLOBAL_KERNELS_DIR}/${KERNEL_NAME}/kernel.json" <<EOF
{
 "argv": [
  "${GLOBAL_KERNELS_DIR}/${KERNEL_NAME}/kernel.sh",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "VBT Kernel-${KERNEL_VERSION}",
 "language": "python"
}
EOF

# 3.3 - Create link to kernel specs
echo "Creating symbolic link: ${GLOBAL_KERNELS_DIR}/${KERNEL_NAME} -> ${KERNEL_SPECS_DIR}/${KERNEL_NAME}"
ln -s ${GLOBAL_KERNELS_DIR}/${KERNEL_NAME} ${KERNEL_SPECS_DIR}/${KERNEL_NAME}

echo -e "\n\nThe new kernel '${KERNEL_NAME}' was added to your kernels in '${KERNEL_SPECS_DIR}/'\n"
ls -l ${KERNEL_SPECS_DIR}/${KERNEL_NAME}
ls ${KERNEL_SPECS_DIR}
tar -czf "${KERNELS_DIR}/${KERNEL_NAME}.tar.gz" -C "${KERNELS_DIR}" "${KERNEL_NAME}"
