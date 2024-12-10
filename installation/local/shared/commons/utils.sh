delete_if_empty() {
  local file_path="$1"

  # Check if the file exists and is empty
  if [[ -f "$file_path" && ! -s "$file_path" ]]; then
    echo "The file '$file_path' is empty. Deleting it..."
    rm "$file_path"
    echo "File deleted."
  else
    echo "The file '$file_path' is not empty or does not exist."
  fi
}