#!/bin/bash

KERNEL_NAME="vbt-spack-env"
KERNEL_DIR="/home/vagrant/.local/share/jupyter/kernels/$KERNEL_NAME"

# Only install if the kernel doesn't already exist
if [ ! -d "$KERNEL_DIR" ]; then
  echo "Kernel not found. Creating kernel: $KERNEL_NAME"

  # Install the ipykernel
  if [ "$DEPLOY_TYPE" = "local" ]; then
    echo "Installing kernel for current user..."

    python3 -m ipykernel install --user --name="$KERNEL_NAME"
  elif [ "$DEPLOY_TYPE" = "hpc" ]; then
    echo "Installing kernel globally..."
    sudo python3 -m ipykernel install --name="$KERNEL_NAME"
  else
    echo "Error: on deployment type was provided."
    exit 1
  fi
  python3 -m ipykernel install --user --name="$KERNEL_NAME"

  # Confirm that the kernel directory was created
  if [ ! -d "$KERNEL_DIR" ]; then
    echo "Error: Kernel directory not found at $KERNEL_DIR after installation."
    exit 1
  fi

  # Copy the custom launch script
  cp "/home/vagrant/shared/kernel.sh" "$KERNEL_DIR/kernel.sh"
  chmod +x "$KERNEL_DIR/kernel.sh"
  dos2unix "$KERNEL_DIR/kernel.sh"

  # Create a custom kernel.json
  cat > "$KERNEL_DIR/kernel.json" <<EOF
{
 "argv": [
  "$KERNEL_DIR/kernel.sh",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "vbt-spack-kernel",
 "language": "python"
}
EOF
fi
