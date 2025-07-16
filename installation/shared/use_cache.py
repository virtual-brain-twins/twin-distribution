import os
from dedal.configuration.SpackConfig import SpackConfig
from dedal.enum.SpackViewEnum import SpackViewEnum
from dedal.spack_factory.SpackOperationCreator import SpackOperationCreator
import shutil
from commons.utils import append_command_to_file
from commons.utils import check_installed_all_spack_packages
from commons.Deploy_Type import DeployType
from vbt_config import user, home_path, set_env_vars, install_dir, data_dir, bashrc_path, buildcache_dir, \
    concretization_dir, vbt_env, ebrains_repo, vbt_spack_env_name, deploy_type

if __name__ == "__main__":
    spack_config = SpackConfig(env=vbt_env,
                               view=SpackViewEnum.VIEW,
                               repos=[ebrains_repo],
                               install_dir=install_dir,
                               upstream_instance=None,
                               system_name=os.getenv('SYSTEMNAME'),
                               gpg=None,
                               concretization_dir=concretization_dir,
                               buildcache_dir=buildcache_dir,
                               use_spack_global=False,
                               cache_version_build=os.getenv('BUILDCACHE_OCI_VERSION'),
                               cache_version_concretize=os.getenv('CONCRETIZE_OCI_VERSION'),
                               bashrc_path=bashrc_path)

    spack_operation = SpackOperationCreator.get_spack_operator(spack_config, use_cache=True)
    spack_operation.install_spack('0.23.1', bashrc_path=bashrc_path)
    if user:
        set_env_vars()
        append_command_to_file(command=f'sudo chown -R {user}:{user} {install_dir}',
                               file_path=f'{home_path}/.bashrc')
        spack_path = str(install_dir / 'spack')
        append_command_to_file(command=f'sudo chown -R {user}:{user} {spack_path}',
                               file_path=f'{home_path}/.bashrc')
        ebrains_env_path = str(data_dir / 'ebrains-spack-builds')
        append_command_to_file(command=f'sudo chown -R {user}:{user} {ebrains_env_path}',
                               file_path=f'{home_path}/.bashrc')
        vbt_env_path = str(data_dir / vbt_spack_env_name)
        append_command_to_file(command=f'sudo chown -R {user}:{user} {vbt_env_path}',
                               file_path=f'{home_path}/.bashrc')
    spack_operation.setup_spack_env()
    spack_operation.reindex()
    spack_operation.update_buildcache_index(spack_operation.spack_config.buildcache_dir)
    spack_operation.concretize_spack_env()
    spack_operation.install_packages(os.cpu_count())
    spack_operation.remove_mirror('local_cache')
    spack_operation.spack_clean()
    if concretization_dir.exists() and concretization_dir.is_dir():
        shutil.rmtree(concretization_dir)
    if buildcache_dir.exists() and buildcache_dir.is_dir():
        shutil.rmtree(buildcache_dir)
    if not check_installed_all_spack_packages(data_dir / vbt_env.name, spack_operation):
        print('false')
    else:
        print('true')
    if user:
        append_command_to_file(command=f'spack env activate -p {str(data_dir / vbt_spack_env_name)}',
                               file_path=f'{home_path}/.bashrc')
        if deploy_type == DeployType.LOCAL.value:
            append_command_to_file(command=f'dos2unix {install_dir}/shared/create_vbt_kernel.sh',
                                   file_path=f'{home_path}/.bashrc')
            append_command_to_file(command=f'dos2unix {install_dir}/shared/remove_kernel.sh',
                                   file_path=f'{home_path}/.bashrc')
            append_command_to_file(command=f'sudo chown -R {user}:{user} {install_dir}/shared/remove_kernel.sh',
                                   file_path=f'{home_path}/.bashrc')
            append_command_to_file(command=f'chmod +x {install_dir}/shared/remove_kernel.sh',
                                   file_path=f'{home_path}/.bashrc')
            append_command_to_file(command=f'sudo chown -R {user}:{user} {install_dir}/shared/create_vbt_kernel.sh',
                                   file_path=f'{home_path}/.bashrc')
            append_command_to_file(command=f'chmod +x {install_dir}/shared/create_vbt_kernel.sh',
                                   file_path=f'{home_path}/.bashrc')
            append_command_to_file(command=f'bash {install_dir}/shared/create_vbt_kernel.sh',
                                   file_path=f'{home_path}/.bashrc')
            append_command_to_file(command=f'bash {install_dir}/shared/remove_kernel.sh',
                                   file_path=f'{home_path}/.bashrc')
            append_command_to_file(command='jupyter lab --allow-root --ip=0.0.0.0 --no-browser',
                                   file_path=f'{home_path}/.bashrc')
    os.system("exec bash")
