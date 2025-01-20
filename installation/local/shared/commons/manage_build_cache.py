import os
import logging
import oras.client
from pathlib import Path

from installation.local.shared.commons.utils import clean_up


class BuildCacheManager:
    """
        This class aims to manage the push/pull/delete of build cache files
    """
    def __init__(self, auth_backend: str):
        self.home_path = Path(os.environ.get("HOME_PATH", os.getcwd()))
        self.log_file = self.home_path / "shared" / "log_oras.txt"
        self.registry_project = os.environ.get("REGISTRY_PROJECT")

        self._registry_username = str(os.environ.get("REGISTRY_USERNAME"))
        self._registry_password = str(os.environ.get("REGISTRY_PASSWORD"))

        self.registry_host = str(os.environ.get("REGISTRY_HOST"))
        # Initialize an OrasClient instance.
        # This method utilizes the OCI Registry for container image and artifact management.
        # Refer to the official OCI Registry documentation for detailed information on the available authentication methods.
        # Supported authentication types may include basic authentication (username/password), token-based authentication,
        self.client = oras.client.OrasClient(hostname=self.registry_host, auth_backend=auth_backend)
        self.client.login(username=self._registry_username, password=self._registry_password)
        self.oci_registry_path = f'{self.registry_host}/{self.registry_project}/cache'

        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S',
            handlers=[
                logging.FileHandler(self.log_file),
                logging.StreamHandler()
            ]
        )

    def oci_registry_upload_build_cache(self, cache_dir: Path):
        """
            This method pushed all the files from the build cache folder into the OCI Registry
        """
        build_cache_path = self.home_path / "shared" / cache_dir
        # build cache folder must exist before pushing all the artifacts
        if not build_cache_path.exists():
            raise FileNotFoundError(
                f"BuildCacheManager::oci_registry_upload_build_cache::Path {build_cache_path} not found.")

        for sub_path in build_cache_path.rglob("*"):
            if sub_path.is_file():
                rel_path = str(sub_path.relative_to(build_cache_path)).replace(str(sub_path.name), "")
                target = f"{self.registry_host}/{self.registry_project}/cache:{str(sub_path.name)}"
                try:
                    logging.info(f"Pushing folder '{sub_path}' to ORAS target '{target}' ...")
                    self.client.push(
                        files=[str(sub_path)],
                        target=target,
                        # save in manifest the relative path for reconstruction
                        manifest_annotations={"path": rel_path},
                        disable_path_validation=True,
                    )
                    logging.info(f"Successfully pushed {sub_path.name}")
                except Exception as e:
                    logging.error(
                        f"BuildCacheManager::registry_upload_build_cache::An error occurred while pushing: {e}")
        # delete the build cache after being pushed to the OCI Registry
        clean_up([str(build_cache_path)], logging)

    def oci_registry_get_tags(self):
        """
            This method retrieves all tags from an OCI Registry
        """
        try:
            return self.client.get_tags(self.oci_registry_path)
        except Exception as e:
            logging.error(f"BuildCacheManager::oci_registry_get_tags::Failed to list tags: {e}")
        return None

    def oci_registry_download_build_cache(self, cache_dir: Path):
        """
            This method pulls all the files from the OCI Registry into the build cache folder
        """
        build_cache_path = self.home_path / "shared" / cache_dir
        # create the buildcache dir if it does not exist
        os.makedirs(build_cache_path, exist_ok=True)
        tags = self.oci_registry_get_tags()
        if tags is not None:
            for tag in tags:
                ref = f"{self.registry_host}/{self.registry_project}/cache:{tag}"
                # reconstruct the relative path of each artifact by getting it from the manifest
                cache_path = \
                    self.client.get_manifest(f'{self.registry_host}/{self.registry_project}/cache:{tag}')[
                        'annotations'][
                        'path']
                try:
                    self.client.pull(
                        ref,
                        # missing dirs to outdir are created automatically by OrasClient pull method
                        outdir=str(build_cache_path / cache_path),
                        overwrite=True
                    )
                    logging.info(f"Successfully pulled artifact {tag}.")
                except Exception as e:
                    logging.error(
                        f"BuildCacheManager::registry_download_build_cache::Failed to pull artifact {tag} : {e}")

    def oci_registry_delete_build_cache(self):
        """
            Deletes all artifacts from an OCI Registry based on their tags.
            This method removes artifacts identified by their tags in the specified OCI Registry.
            It requires appropriate permissions to delete artifacts from the registry.
            If the registry or user does not have the necessary delete permissions, the operation might fail.
        """
        tags = self.oci_registry_get_tags()
        if tags is not None:
            try:
                self.client.delete_tags(self.oci_registry_path, tags)
                logging.info(f"Successfully deleted all artifacts form OCI registry.")
            except RuntimeError as e:
                logging.error(
                    f"BuildCacheManager::registry_delete_build_cache::Failed to delete artifacts: {e}")
