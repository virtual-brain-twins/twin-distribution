# Spack installation according to the official documentation.
echo 'Spack install'
git clone --depth 1 -c advice.detachedHead=false -c feature.manyFiles=true --branch v0.21.1 https://github.com/spack/spack

echo "Cloned spack"
. spack/share/spack/setup-env.sh
echo 'export PATH="/home/vagrant/spack/bin:$PATH"' >> /home/vagrant/.bashrc
echo 'source /home/vagrant/spack/share/spack/setup-env.sh' >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc

sudo chown -R $USER:$USER /home/vagrant/spack/
echo "Install spack"
spack --version
