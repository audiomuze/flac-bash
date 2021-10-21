#!/bin/bash

search_dir() {
          cd "$1" || return
          if [ -f dr14.txt ]; then
                  printf "%s|" "$PWD" >> /tmp/dr_scores.csv
                  sed '/^ *Official DR value: */{s///;H;};$!d;x;s/^\n//;s/\n/ /g' dr14.txt >> /tmp/dr_scores.csv
          fi
}

export -f search_dir
find "$PWD" -type d \( ! -name . \) -execdir bash -c 'search_dir "$0"' {} \;
