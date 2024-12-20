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

extract_first_file() {
  local dir_path="$1"

  if [ ! -d "$dir_path" ]; then
    echo "Error: '$dir_path' is not a valid directory." >&2
    return 1
  fi

  # Find the first file in the directory
  local first_file=$(find "$dir_path" -type f | head -n 1)

  if [ -z "$first_file" ]; then
    echo "No files found in the directory." >&2
    return 1
  fi

  basename "$first_file"
}