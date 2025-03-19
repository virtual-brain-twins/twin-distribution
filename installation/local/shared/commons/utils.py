import os

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
