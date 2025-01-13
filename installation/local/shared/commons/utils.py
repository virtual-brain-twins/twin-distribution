import shutil
from pathlib import Path


def clean_up(dirs: list[str], logging):
    """
        All the folders from the list dirs are removed with all the content in them
    """
    for cleanup_dir in dirs:
        cleanup_dir = Path(cleanup_dir).resolve()
        if cleanup_dir.exists():
            logging.info(f"Removing {cleanup_dir}")
            shutil.rmtree(Path(cleanup_dir))
        else:
            logging.info(f"{cleanup_dir} does not exist")
