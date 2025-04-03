import os
from pathlib import Path

from dedal.model.SpackDescriptor import SpackDescriptor
from dedal.utils.utils import set_bashrc_variable

user = None
home_path = None
bashrc_path = None

try:
    user = os.getlogin()
    if user:
        home_path = f'/home/{user}'
        bashrc_path = f'{home_path}/.bashrc'
except OSError:
    user = None
    home_path = None
    bashrc_path = None

vbt_spack_env_access_token = os.getenv('VBT_SPACK_ENV_ACCESS_TOKEN')
vbt_spack_env_name = os.getenv('VBT_SPACK_ENV_NAME')

if home_path:
    install_dir = Path(f'{home_path}/').resolve()
else:
    install_dir = Path('../').resolve()
data_dir = install_dir / 'data'
os.makedirs(data_dir, exist_ok=True)
concretization_dir = data_dir / 'concretize_cache'
buildcache_dir = data_dir / 'binary_cache'

ebrains_spack_builds_git = 'https://gitlab.ebrains.eu/ri/tech-hub/platform/esd/ebrains-spack-builds.git'
spack_env_git = f'https://oauth2:{vbt_spack_env_access_token}@gitlab.ebrains.eu/ri/projects-and-initiatives/virtualbraintwin/tools/{vbt_spack_env_name}.git'

ebrains_repo = SpackDescriptor('ebrains-spack-builds', data_dir, ebrains_spack_builds_git)
vbt_env = SpackDescriptor(vbt_spack_env_name, data_dir, spack_env_git)


def set_env_vars():
    print(bashrc_path)
    if bashrc_path:
        set_bashrc_variable('BUILDCACHE_OCI_HOST', os.getenv('BUILDCACHE_OCI_HOST'), bashrc_path=bashrc_path)
        set_bashrc_variable('BUILDCACHE_OCI_PASSWORD', os.getenv('BUILDCACHE_OCI_PASSWORD'), bashrc_path=bashrc_path)
        set_bashrc_variable('BUILDCACHE_OCI_PROJECT', os.getenv('BUILDCACHE_OCI_PROJECT'), bashrc_path=bashrc_path)
        set_bashrc_variable('BUILDCACHE_OCI_USERNAME', os.getenv('BUILDCACHE_OCI_USERNAME'), bashrc_path=bashrc_path)
        set_bashrc_variable('BUILDCACHE_OCI_VERSION', os.getenv('BUILDCACHE_OCI_VERSION'), bashrc_path=bashrc_path)
        set_bashrc_variable('CONCRETIZE_OCI_HOST', os.getenv('CONCRETIZE_OCI_HOST'), bashrc_path=bashrc_path)
        set_bashrc_variable('CONCRETIZE_OCI_PASSWORD', os.getenv('CONCRETIZE_OCI_PASSWORD'), bashrc_path=bashrc_path)
        set_bashrc_variable('CONCRETIZE_OCI_PROJECT', os.getenv('CONCRETIZE_OCI_PROJECT'), bashrc_path=bashrc_path)
        set_bashrc_variable('CONCRETIZE_OCI_USERNAME', os.getenv('CONCRETIZE_OCI_USERNAME'), bashrc_path=bashrc_path)
        set_bashrc_variable('CONCRETIZE_OCI_VERSION', os.getenv('CONCRETIZE_OCI_VERSION'), bashrc_path=bashrc_path)
        set_bashrc_variable('VBT_SPACK_ENV_ACCESS_TOKEN', os.getenv('VBT_SPACK_ENV_ACCESS_TOKEN'), bashrc_path=bashrc_path)
        set_bashrc_variable('VBT_SPACK_ENV_NAME', os.getenv('VBT_SPACK_ENV_NAME'), bashrc_path=bashrc_path)
