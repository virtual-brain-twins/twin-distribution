from pathlib import Path
from dedal.configuration.GpgConfig import GpgConfig
from dedal.configuration.SpackConfig import SpackConfig
import os
from dedal.spack_factory.SpackOperationCreator import SpackOperationCreator
from commons.utils import check_installed_all_spack_packages
from vbt_config import set_env_vars, data_dir, install_dir, bashrc_path, concretization_dir, buildcache_dir, vbt_env, \
    ebrains_repo

if __name__ == "__main__":
    set_env_vars()
    spack_config = SpackConfig(env=vbt_env,
                               repos=[ebrains_repo],
                               install_dir=install_dir,
                               upstream_instance=None,
                               system_name='VBT',
                               concretization_dir=concretization_dir,
                               buildcache_dir=buildcache_dir,
                               gpg=GpgConfig('vbt', 'science@codemart.ro'),
                               use_spack_global=False,
                               cache_version_build=os.getenv('BUILDCACHE_OCI_VERSION'),
                               cache_version_concretize=os.getenv('CONCRETIZE_OCI_VERSION'),
                               override_cache=False,
                               bashrc_path=bashrc_path)
    spack_operation = SpackOperationCreator.get_spack_operator(spack_config, use_cache=False)
    spack_operation.install_spack('0.23.1', bashrc_path=bashrc_path)
    spack_operation.setup_spack_env()
    spack_operation.concretize_spack_env()
    spack_operation.install_packages(os.cpu_count())
    if not check_installed_all_spack_packages(Path('../local/').resolve() / data_dir / vbt_env.name, spack_operation):
        print('false')
    else:
        print('true')
