import os
from pathlib import Path
import sys
from dedal.configuration.SpackConfig import SpackConfig
from dedal.spack_factory.SpackOperationCreator import SpackOperationCreator

from commons.utils import append_command_to_file
from commons.utils import check_installed_all_spack_packages
from vbt_config import user, home_path, set_env_vars, install_dir, data_dir, bashrc_path, buildcache_dir, \
    concretization_dir, vbt_env, ebrains_repo, vbt_spack_env_name

if __name__ == "__main__":
    if user:
        set_env_vars()
        spack_path = str(data_dir / 'spack')
        append_command_to_file(command=f'sudo chown -R {user}:{user} {spack_path}',
                               file_path=f'{home_path}/.bashrc')
        ebrains_path = str(data_dir / 'ebrains-spack-builds')
        append_command_to_file(command=f'sudo chown -R {user}:{user} {ebrains_path}',
                               file_path=f'{home_path}/.bashrc')
        append_command_to_file(command=f'sudo chown -R {user}:{user} {data_dir / {vbt_spack_env_name} }',
                               file_path=f'{home_path}/.bashrc')

    spack_config = SpackConfig(env=vbt_env,
                               repos=[ebrains_repo],
                               install_dir=install_dir,
                               upstream_instance=None,
                               system_name='VBT',
                               concretization_dir=concretization_dir,
                               buildcache_dir=buildcache_dir,
                               gpg=None,
                               use_spack_global=False,
                               cache_version_build=os.getenv('BUILDCACHE_OCI_VERSION'),
                               cache_version_concretize=os.getenv('CONCRETIZE_OCI_VERSION'))

    spack_operation = SpackOperationCreator.get_spack_operator(spack_config, use_cache=True)
    spack_operation.install_spack('0.23.1', bashrc_path=bashrc_path)
    spack_operation.setup_spack_env()
    spack_operation.concretize_spack_env()
    spack_operation.install_packages(os.cpu_count())
    if not check_installed_all_spack_packages(data_dir / vbt_env.name, spack_operation):
        sys.exit(-1)
    if user:
        append_command_to_file(command=f'spack env activate -p {str(data_dir / vbt_spack_env_name)}',
                               file_path=f'{home_path}/.bashrc')
    os.system("exec bash")
