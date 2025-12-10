#!/bin/bash

#set -euxo pipefail

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

# 1. Create the kernel
export KERNEL_DIR=${KERNELS_DIR}/${KERNEL_NAME}
if [ -d "${KERNEL_DIR}" ]; then
  echo "ERROR: Directory for kernel ${KERNEL_NAME} already ${KERNEL_DIR}"
  exit 1
fi



# 1.1 Create easybuild file for the VBT Spack environment
cat > "./vbt-kernel-${KERNEL_VERSION}-gpsfbf-${GPSFBF_VERSION}.eb" <<EOF
# Built with EasyBuild version 4.9.4 on 2025-10-29_09-40-14
import os as local_os

easyblock = 'Bundle'
name = 'vbt-kernel'
version = '${KERNEL_VERSION}'

homepage = 'https://www.virtualbraintwin.eu/'

description = (
    "VBT Kernel testing with EasyBuild"
)

toolchain = {'name': 'gpsfbf', 'version': '${GPSFBF_VERSION}'}

local_system_name = local_os.getenv('SYSTEMNAME')

# Disable local Spack user configuration
modextravars = {'SPACK_DISABLE_LOCAL_CONFIG': 'true'}

# Spack handles libraries via RPATH, so only minimal paths are needed
local_spack_view = (
    f"/p/scratch/vbt/vbt-spack/vbt_spack_kernel/${KERNEL_VERSION}/virtualbraintwin/installation/data/vbt-spack-env/.spack-env/view"
)

modluafooter = f"""
-- Spack view path
prepend_path("PATH", "{local_spack_view}/bin")
prepend_path("PYTHONPATH", "{local_spack_view}/lib/python${PYTHON_VERSION}/site-packages")
"""

moduleclass = 'tools'
EOF

chmod +x ./vbt-kernel-${KERNEL_VERSION}-gpsfbf-${GPSFBF_VERSION}.eb
module --force purge
module load Stages/${STAGES_VERSION}
export USERINSTALLATIONS=$PROJECT_vbt
module load UserInstallations
ml
eb vbt-kernel-${KERNEL_VERSION}-gpsfbf-${GPSFBF_VERSION}.eb

# 2.1 - Load basic Python module
module purge
module load Stages/${STAGES_VERSION}
module load GCC
module load Python

# 2.2 Create kernel.sh and launch the vbt-spack-env
cat > "./kernel.sh" <<EOF
#!/bin/bash

export USERINSTALLATIONS=$PROJECT_vbt
module purge
module load Stages/${STAGES_VERSION}
module load GCC/${GCC_VERSION}
module load ParaStationMPI/${ParaStationMPI_VERSION}
module load vbt-kernel/${KERNEL_VERSION}

EOF

chmod +x "./kernel.sh"

chmod +x "./vbt-spack_env.sh"
source ./vbt-spack_env.sh

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
