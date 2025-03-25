import os
from dedal.configuration.SpackConfig import SpackConfig
from dedal.model.SpackDescriptor import SpackDescriptor
from dedal.spack_factory.SpackOperationCreator import SpackOperationCreator

from commons.utils import append_command_to_file
from vbt_config import user, home_path, set_env_vars, install_dir, data_dir, spack_env_git, \
    ebrains_spack_builds_git, bashrc_path, buildcache_dir, concretization_dir

if __name__ == "__main__":
    set_env_vars()
    if home_path:
        append_command_to_file(command=f'sudo chown -R {user}:{user} {home_path}/spack',
                               file_path=f'{home_path}/.bashrc')
        append_command_to_file(command=f'sudo chown -R {user}:{user} {home_path}/caching/ebrains-spack-builds',
                               file_path=f'{home_path}/.bashrc')
        append_command_to_file(command=f'sudo chown -R {user}:{user} {home_path}/caching/vbt-spack-env',
                               file_path=f'{home_path}/.bashrc')
        append_command_to_file(command=f'spack env activate -p {home_path}/caching/vbt-spack-env',
                               file_path=f'{home_path}/.bashrc')
    spack_config = SpackConfig(env=SpackDescriptor('vbt-spack-env', data_dir, spack_env_git),
                               repos=[SpackDescriptor('ebrains-spack-builds', data_dir, ebrains_spack_builds_git)],
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
    os.system("exec bash")
