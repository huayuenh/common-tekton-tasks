#!/usr/bin/env bash

create_new_version() {
  local resource_type=$1
  local resource_name=$2
  local old_version=$3
  local new_version=$4

  local old_path="stable/$resource_type/$resource_name/$old_version"
  local new_path="stable/$resource_type/$resource_name/$new_version"

  mkdir -p "$new_path"
  cp "$old_path"/* "$new_path"
}

if [[ $# -ne 4 ]]; then
    echo "Error:   Illegal number of parameters."
    echo "Usage:   ./scripts/create-new-version <resource-type> <resource-name> <old-version> <new-version>"
    echo "Example: ./scripts/create-new-version task my-task 1.0.0 2.0.0"
    exit 1
fi

create_new_version "$1" "$2" "$3" "$4"
