from pathlib import Path
from dedal.configuration.SpackConfig import SpackConfig
import os
import shutil
from dedal.enum.SpackViewEnum import SpackViewEnum
from dedal.spack_factory.SpackOperationCreator import SpackOperationCreator
from commons.utils import check_installed_all_spack_packages
from vbt_config import set_env_vars, data_dir, install_dir, bashrc_path, concretization_dir, buildcache_dir, vbt_env, \
    ebrains_repo

if __name__ == "__main__":
    set_env_vars()
    spack_config = SpackConfig(env=vbt_env,
                               view=SpackViewEnum.VIEW,
                               repos=[ebrains_repo],
                               install_dir=install_dir,
                               upstream_instance=None,
                               system_name=os.getenv('SYSTEMNAME'),
                               concretization_dir=concretization_dir,
                               gpg=None,
                               buildcache_dir=buildcache_dir,
                               use_spack_global=False,
                               cache_version_build=os.getenv('BUILDCACHE_OCI_VERSION'),
                               cache_version_concretize=os.getenv('CONCRETIZE_OCI_VERSION'),
                               override_cache=False,
                               bashrc_path=bashrc_path)

    spack_operation = SpackOperationCreator.get_spack_operator(spack_config, use_cache=False)
    spack_operation.install_spack('0.23.1', bashrc_path=bashrc_path)
    spack_operation.setup_spack_env()
    spack_operation.concretize_spack_env()
    spack_operation.install_packages(min(os.cpu_count() or 1, 10))
    spack_operation.remove_mirror('local_cache')
    spack_operation.spack_clean()
    if concretization_dir.exists() and concretization_dir.is_dir():
        shutil.rmtree(concretization_dir)
    if buildcache_dir.exists() and buildcache_dir.is_dir():
        shutil.rmtree(buildcache_dir)
    if not check_installed_all_spack_packages(Path('../').resolve() / data_dir / vbt_env.name, spack_operation):
        print('false')
    else:
        print('true')
