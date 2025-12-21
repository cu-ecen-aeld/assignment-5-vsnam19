#!/bin/sh

# Write a shell script finder-app/finder.sh as described below:
# - Accepts the following runtime arguments: the first argument is a path to a directory on the filesystem, referred to below as filesdir; 
# the second argument is a text string which will be searched within these files, referred to below as searchstr
# - Exits with return value 1 error and print statements if any of the parameters above were not specified
# - Exits with return value 1 error and print statements if filesdir does not represent a directory on the filesystem
# - Prints a message "The number of files are X and the number of matching lines are Y" where X is the number of files in the directory and
# all subdirectories and Y is the number of matching lines found in respective files, where a matching line refers to a line which contains searchstr 
# (and may also contain additional content).
check_params_for_empty() {
  for i in "$@"; do
    if [[ -z "$i" ]]; then
      echo "Error: Missing argument(s)." >&2
      exit 1
    fi
  done
}

check_dir_exist() {
  if [[ ! -d "$1" ]]; then
    echo "Error: '$1' is not a valid directory." >&2
    exit 1
  fi
}

if  [ $# -lt 2 ]; then
    echo "Error: Missing parameter"
    exit 1 
fi

filesdir=$1
searchstr=$2

check_params_for_empty "$filesdir" "$searchstr"
check_dir_exist "$filesdir"

no_files=$(find "$filesdir" -type f | wc -l)
no_matches=$(grep -R "$searchstr" "$filesdir" 2>/dev/null | wc -l)

echo "The number of files are $no_files and the number of matching lines are $no_matches"
