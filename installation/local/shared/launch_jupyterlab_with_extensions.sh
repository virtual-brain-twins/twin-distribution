#!/usr/bin/env bash
# run with source: source ./launch_jupyterlab_with_extensions.sh
# List of extensions installed with spack

JUPYTER_EXTENSIONS=(
    "py-tvb-ext-bucket"
    "py-tvb-ext-unicore"
    "py-tvb-ext-xircuits"
)

is_in_jupyter_path() {
    local path=$1
    if [[ ":$JUPYTER_PATH:" == *":$path:"* ]]; then
        return 0
    else
        return 1
    fi
}

main() {
    for ext in "${JUPYTER_EXTENSIONS[@]}"
    do
        echo "Adding to jupyter path JupyterLab extension: $ext"
        ext_path=$(spack location -i $ext)
        if [ -z "$ext_path" ]; then
            echo "Error: Could not find installation location for $ext"
            continue
        fi
        echo "$(is_in_jupyter_path "$jupyter_ext_path")"
        if is_in_jupyter_path "$jupyter_ext_path"; then
            echo "Path $jupyter_ext_path is already in JUPYTER_PATH, skipping."
        else
            export JUPYTER_PATH=$JUPYTER_PATH:$jupyter_ext_path
        fi
    done

    echo "$JUPYTER_PATH"

    spack load node-js
    spack load npm
    spack load py-jupyterlab@3.4.8
    spack load py-jupyterlab-server
    spack load py-jupyter-server
    spack load py-tvb-ext-bucket
    spack load py-tvb-ext-unicore
    spack load py-tvb-ext-xircuits
    echo "Loaded packages"

    echo "Starting jupyter lab with tvb extensions"
    jupyter lab --allow-root --ip=0.0.0.0 --no-browser
}

main


