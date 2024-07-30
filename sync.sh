#!/bin/bash

# Exit on error
set -e

# Check commands are available
_check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo "Error: $1 is not installed or not in your PATH."
    exit 1
  fi
}
_check_command "spotdl"
_check_command "tee"

# Save the current directory and file paths
root_dir=$(pwd)
csv_file="$root_dir/config.csv"
sync_dir="$root_dir/sync"

# Validate the current directory matches the expected name and the config file exists
if [ "$(basename "$root_dir")" != "spotify-sync" ]; then
  echo "Error: This script must be run from the 'spotify-sync' directory."
  exit 1
fi
if [ ! -f "$csv_file" ]; then
  echo "Error: File '$csv_file' does not exist."
  exit 1
fi

# Validate the CSV format
awk -F',' '
  BEGIN {
    valid=1
  }
  NR==1 {
    # Check header
    if ($1 != "playlist_url" || $2 != "folder_name") {
      print "Error: Invalid header in CSV file."
      valid=0
    }
  }
  NR>1 {
    # Check if the line has exactly 2 columns and all values are filled
    if (NF != 2 || $1 == "" || $2 == "") {
      print "Error: Invalid row in CSV file at line " NR "."
      valid=0
    }
  }
  END {
    if (valid == 0) {
      exit 1
    }
  }
' "$csv_file"

# Check valid CSV
if ! [ $? -eq 0 ]; then
  echo "Error: CSV file contains formatting issues."
  exit 1
fi

# Process each row
tail -n +2 "$csv_file" | while IFS=, read -r playlist_url folder_name; do

  # Start from the sync directory
  mkdir -p "$sync_dir"
  cd "$sync_dir" || exit

  # Create directory if not exists and cd into it
  playlist_folder="$sync_dir/$folder_name"
  mkdir -p "$playlist_folder"
  cd "$playlist_folder" || exit

  # Create log folder if not exists
  mkdir -p "$playlist_folder/logs"

  # Run the spotdl command to sync the playlist and save logs output
  echo "Syncing Playlist ($playlist_url) with folder $playlist_folder"
  spotdl sync "$playlist_url" --save-file "$playlist_folder/config.spotdl" | tee "$playlist_folder/logs/$(date "+%Y_%m_%d__%H_%M_%S").txt"
  echo -e "✅ '$(basename "$playlist_folder")' successfully synced 🎉🎉🎉\n\n"

  # Change back to the sync directory
  cd "$sync_dir" || exit

  echo
done
