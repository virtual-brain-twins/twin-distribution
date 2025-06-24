#!/usr/bin/env bash
set -e
git clone -b generate-cache-job https://gitlab.jsc.fz-juelich.de/virtualbraintwin/virtualbraintwin.git
cd ./instalation/local
mkdir -p data
cd ./data
git clone https://oauth2:glpat-zpNBhLLm5PPGLk29gYAp@gitlab.ebrains.eu/ri/projects-and-initiatives/virtualbraintwin/tools/vbt-spack-env.git
git clone -c feature.manyFiles=true --depth=2 -b v0.23.1 https://github.com/spack/spack.git
source ./spack/share/spack/setup-env.sh
spack env activate -p vbt-spack-env
git clone https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/ebrains-spack-builds.git
spack repo add ebrains-spack-builds
spack concretize --force
spack install --fresh