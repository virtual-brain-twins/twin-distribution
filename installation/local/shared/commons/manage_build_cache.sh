#!/usr/bin/env bash
registry_upload_build_cache(){
    push_failed=false
    for path in $(find $HOME_PATH/shared/local_cache -mindepth 1); do
      echo "Pushing ${path} to ORAS..."
      package_name=$(basename ${path})
      echo $REGISTRY_PASSWORD | oras push \
        --annotation="path=$package_name" \
        --username $REGISTRY_USERNAME \
        --password-stdin \
        --disable-path-validation \
        $REGISTRY_HOST/$REGISTRY_PROJECT/cache:$package_name ${path} \
        2> >(ts > $HOME_PATH/shared/log_oras.txt)
        ret=$?
        if [ ${ret} -ne 0 ]; then
          echo "Uploading of \"$package_name\" to OCI cache failed."
          push_failed=true
        fi
      done
      if [ "$push_failed" = false ]; then
          echo "Local clean up"
          rm -rf ebrains-spack-builds
          rm -rf twin-spack-env
          rm -rf $HOME_PATH/shared/local_cache
      else
        echo "Something went wrong during uploading of the build cache to the OCI."
      fi
}

registry_download_build_cache(){
  echo "Fetching artifact list from ORAS registry..."

  artifact_tags=$(echo $REGISTRY_PASSWORD | oras repo tags \
      --username $REGISTRY_USERNAME \
      --password-stdin  \
      $REGISTRY_HOST/$REGISTRY_PROJECT/cache)

  if [ -z "$artifact_tags" ]; then
      echo "No artifacts found in ${HARBOR_HOST}/${HARBOR_PROJECT}/cache."
      exit 0
  fi

  for artifact in $artifact_tags; do
      echo "Pulling artifact: cache:${artifact}"

      echo $REGISTRY_PASSWORD |oras pull \
          --username $REGISTRY_USERNAME \
          --password-stdin \
          $REGISTRY_HOST/$REGISTRY_PROJECT/cache:${artifact} \
          2> >(ts > $HOME_PATH/shared/log_oras.txt)
      ret=$?
      if [ $ret -ne 0 ]; then
          echo "Failed to pull artifact ${artifact}. Skipping..."
      else
          echo "Successfully pulled artifact ${artifact}."
      fi
  done

  echo "All artifacts pulled into local_cache."
}

registry_delete_build_cache(){
  artifact_tags=$(echo $REGISTRY_PASSWORD | oras repo tags \
      --username $REGISTRY_USERNAME \
      --password-stdin \
      $REGISTRY_HOST/$REGISTRY_PROJECT/cache)

  for TAG in $artifact_tags; do
      # Fetch the digest for the tag
      DIGEST=$(oras manifest fetch --descriptor "$REGISTRY_HOST/$REGISTRY_PROJECT/cache:${TAG}" | jq -r '.digest')
      echo "Processing digest: ${DIGEST}..."

      if [ -z "$DIGEST" ]; then
          echo "Failed to fetch digest for tag: ${TAG}. Skipping."
          continue
      fi

      # Delete the manifest by its digest
      echo $REGISTRY_PASSWORD | oras manifest delete --force \
      --username $REGISTRY_USERNAME \
      --password-stdin \
      "$REGISTRY_HOST/$REGISTRY_PROJECT/cache@${DIGEST}"
      if [ $? -eq 0 ]; then
          echo "Deleted manifest: ${DIGEST} (Tag: ${TAG})"
      else
          echo "Failed to delete manifest: ${DIGEST} (Tag: ${TAG})"
      fi
  done
}

