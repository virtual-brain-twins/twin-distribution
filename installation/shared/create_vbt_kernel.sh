# Create vbt-spack-kernel for jupyter lab
KERNEL_NAME="vbt-spack-env"
KERNEL_DIR="/home/vagrant/.local/share/jupyter/kernels/$KERNEL_NAME"
#chmod -R 777 /home/vagrant

python3 -m ipykernel install --user --name="$KERNEL_NAME"

if [ ! -d "$KERNEL_DIR" ]; then
  echo "Error: Kernel directory not found at $KERNEL_DIR"
  exit 1
fi

cp "/home/vagrant/shared/kernel.sh" "$KERNEL_DIR/kernel.sh"
chmod +x "$KERNEL_DIR/kernel.sh"

cat > "$KERNEL_DIR/kernel.json" <<EOF
{
 "argv": [
  "/home/vagrant/.local/share/jupyter/kernels/vbt-spack-env",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "vbt-spack-kernel",
 "language": "python"
}
EOF