#!/bin/bash

touch_dir() {
          cd "$1" || return
          # uncomment if you want to use file date and timestamps only
          oldest_file="$(find "$PWD" -mindepth 1 -maxdepth 1 -type f -printf '%T+ %p\n' | sort | head -1| cut -d' ' -f2-)"
          # uncomment if you want to use file and/or folder date and timestamps
          #oldest_file="$(find "$PWD" -mindepth 1 -maxdepth 1 -printf '%T+ %p\n' | sort | head -1 | cut -d' ' -f2-)"

if [ -n "$oldest_file" ]

then

      echo "Processing "$PWD""
      # set date and timestamp of all files and parent folder using reference file
      find "$PWD" -mindepth 1 -maxdepth 1 -type f -print0 | xargs -I {} -0 touch -m -r "$oldest_file" "{}"
      touch -m -r "$oldest_file" "$PWD"

fi
}

export -f touch_dir
find "$PWD" -type d \( ! -name . \) -execdir bash -c 'touch_dir "$0"' {} \;
