from dedal.configuration.GpgConfig import GpgConfig
from dedal.configuration.SpackConfig import SpackConfig
from dedal.model.SpackDescriptor import SpackDescriptor
import os

from dedal.spack_factory.SpackOperationCreator import SpackOperationCreator

from vbt_config import set_env_vars, data_dir, \
    spack_env_git, ebrains_spack_builds_git, install_dir, bashrc_path, concretization_dir, buildcache_dir

if __name__ == "__main__":
    set_env_vars()
    spack_config = SpackConfig(env=SpackDescriptor('vbt-spack-env', data_dir, spack_env_git),
                               repos=[SpackDescriptor('ebrains-spack-builds', data_dir, ebrains_spack_builds_git)],
                               install_dir=install_dir,
                               upstream_instance=None,
                               system_name='VBT',
                               concretization_dir=concretization_dir,
                               buildcache_dir=buildcache_dir,
                               gpg=GpgConfig('vbt', 'science@codemart.ro'),
                               use_spack_global=False,
                               cache_version_build=os.getenv('BUILDCACHE_OCI_VERSION'),
                               cache_version_concretize=os.getenv('CONCRETIZE_OCI_VERSION'))
    spack_operation = SpackOperationCreator.get_spack_operator(spack_config, use_cache=False)
    spack_operation.install_spack('0.23.1', bashrc_path=bashrc_path)
    spack_operation.setup_spack_env()
    spack_operation.concretize_spack_env()
    spack_operation.install_packages(os.cpu_count())
