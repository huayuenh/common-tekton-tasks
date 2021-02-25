#!/usr/bin/env bash

declare -A versions

for resource in stable/*; do
  while read -r version; do
    # link major.minor -> major.minor.patch
    # ln -fhs "$(basename "$version")" "$(dirname "$version")/$(basename "$version" | awk -F. '{print $1"."$2}')"
    versions["$(dirname "$version")/$(basename "$version" | awk -F. '{print $1"."$2}')"]="$(basename "$version")"

    # link major -> major.minor
    # ln -fhs "$(basename "$version" | awk -F. '{print $1"."$2}')" "$(dirname "$version")/$(basename "$version" | awk -F. '{print $1}')"
    versions["$(dirname "$version")/$(basename "$version" | awk -F. '{print $1}')"]="$(basename "$version" | awk -F. '{print $1"."$2}')"
  done < <(find "$resource" -type d -mindepth 2 -maxdepth 2 | sort -V)
done

if [[ "$1" == check ]]; then
  ERROR=0
  for k in "${!versions[@]}"; do
    echo -n "$k -> ${versions[$k]}... "
    if [[ "$(readlink "$k")" != "${versions[$k]}" ]]; then
      echo "NOT OK ($(readlink "$k") != ${versions[$k]})"
      ERROR=1
    else
      echo "OK"
    fi
  done
  exit "$ERROR"
fi

for k in "${!versions[@]}"; do
  echo "$k -> ${versions[$k]}"
  ln -fhs "${versions[$k]}" "$k"
done
