#!/bin/bash

current_dir=$(pwd)
module load turbomole/6.6
for dir in */; do
  if [ -d "$dir" ]; then
    cd "$dir"
    sed -i "/implicit core/d" control
    echo -e "\n\n\n\n"|tm2molden
    cd "$current_dir"
  fi
done
