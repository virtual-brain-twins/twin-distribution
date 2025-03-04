import os
from pathlib import Path

from dedal.bll.SpackManager import SpackManager
from dedal.configuration.GpgConfig import GpgConfig
from dedal.configuration.SpackConfig import SpackConfig
from dedal.model.SpackDescriptor import SpackDescriptor
from dedal.utils.utils import set_bashrc_variable

bashrc_path = '/home/vagrant/.bashrc'

# todo add '\' before '$' in the OCI_USERNAME
def set_env_vars():
    set_bashrc_variable('BUILDCACHE_OCI_HOST', os.getenv('BUILDCACHE_OCI_HOST'), bashrc_path=bashrc_path)
    set_bashrc_variable('BUILDCACHE_OCI_PASSWORD', os.getenv('BUILDCACHE_OCI_PASSWORD'), bashrc_path=bashrc_path)
    set_bashrc_variable('BUILDCACHE_OCI_PROJECT', os.getenv('BUILDCACHE_OCI_PROJECT'), bashrc_path=bashrc_path)
    set_bashrc_variable('BUILDCACHE_OCI_USERNAME', os.getenv('BUILDCACHE_OCI_USERNAME'), bashrc_path=bashrc_path)
    set_bashrc_variable('CONCRETIZE_OCI_HOST', os.getenv('CONCRETIZE_OCI_HOST'), bashrc_path=bashrc_path)
    set_bashrc_variable('CONCRETIZE_OCI_PASSWORD', os.getenv('CONCRETIZE_OCI_PASSWORD'), bashrc_path=bashrc_path)
    set_bashrc_variable('CONCRETIZE_OCI_PROJECT', os.getenv('CONCRETIZE_OCI_PROJECT'), bashrc_path=bashrc_path)
    set_bashrc_variable('CONCRETIZE_OCI_USERNAME', os.getenv('CONCRETIZE_OCI_USERNAME'), bashrc_path=bashrc_path)


def create_cache():
    set_env_vars()
    install_dir = Path('/home/vagrant/').resolve()
    data_dir = install_dir / 'cashing'
    ebrains_spack_builds_git = 'https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/ebrains-spack-builds.git'
    spack_env_git = f'https://gitlab.ebrains.eu/adrianciu/test-spack-env.git'
    spack_config = SpackConfig(env=SpackDescriptor('twin-spack-env', data_dir, spack_env_git),
                               repos=[SpackDescriptor('ebrains-spack-builds', data_dir, ebrains_spack_builds_git)],
                               install_dir=install_dir,
                               upstream_instance=None,
                               system_name='VBT',
                               concretization_dir=data_dir / 'concretize_cache',
                               buildcache_dir=data_dir / 'binary_cache',
                               gpg=GpgConfig('vbt', 'science@codemart.ro'),
                               use_spack_global=False,
                               # todo get from env vars the cache version for concretization and binary
                               cache_version_build='v1',
                               cache_version_concretize='v1')
    spack_manager = SpackManager(spack_config, use_cache=False)

    spack_manager.install_spack('0.23.1', bashrc_path=bashrc_path)
    spack_manager.setup_spack_env()
    spack_manager.concretize_spack_env()
    spack_manager.install_packages(os.cpu_count())
    spack_operation = spack_manager._get_spack_operation()
    spack_operation.build_cache.upload(spack_operation.spack_config.buildcache_dir)


if __name__ == "__main__":
    create_cache()
