#!/bin/bash


l_buildDir=$1

l_files=$(find ${l_buildDir} -name '*.gcno')
for c_file in $(echo ${l_files}); do
  l_items=$(gcov ${c_file} 2>/dev/null | grep File | sort | cut -d"'" -f2)
  l_found=1
  for c_item in $(echo ${l_items}); do
    if [ ! -f ${c_item} ]; then
        l_found=0
    fi
  done
  if [ "${l_found}" -eq 0 ]; then
      echo "deleting ${c_file}"
      rm -f ${c_file}
  fi
done
