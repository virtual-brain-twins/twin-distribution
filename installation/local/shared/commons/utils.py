import os
from pathlib import Path

from dedal.spack_factory.SpackOperation import SpackOperation
from dedal.utils.spack_utils import extract_spack_packages
from error_handling.exceptions import BashrcException


def append_command_to_file(command: str, file_path: str):
    """
    Appends a command to a file.
    Args:
        command (str): The command to append.
        file_path (str): The file to which the command should be appended.
    """
    try:
        command = os.path.expandvars(command)
        file_path = os.path.expandvars(file_path)
        with open(file_path, 'a') as file:
            file.write(f"{command}\n")
    except Exception as e:
        raise BashrcException(f"Error appending command: {e}")


def check_installed_all_spack_packages(env_path: Path, spack_operation: SpackOperation):
    to_install = extract_spack_packages(env_path / 'spack.yaml')
    installed = spack_operation.find_packages()
    for package in to_install:
        if package not in list(installed.keys()):
            return False
    return True
