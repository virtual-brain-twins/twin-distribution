from pathlib import Path
from commons.manage_build_cache import BuildCacheManager

if __name__ == "__main__":
    cache_manager = BuildCacheManager(auth_backend="basic")
    cache_manager.oci_registry_upload_build_cache(Path('local_cache'))
    cache_manager.oci_registry_download_build_cache(Path('local_cache_pull'))
    cache_manager.oci_registry_delete_build_cache()
