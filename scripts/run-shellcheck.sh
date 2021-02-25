#!/usr/bin/env bash

run_shellcheck_on_task_steps() {
  local task_name=$1
  local version=$2

  for step in $(yq r -j "stable/task/$task_name/$version/$task_name.yaml" | jq -r '.spec.steps[] | @base64' ); do
    local name
    name=$(echo "$step" | base64 --decode | jq -r '.name')
    echo "$step" | base64 --decode | jq -r '.script' > "$name.tmp"
    
    echo "Shellcheck for step '$name':"
    shellcheck "$name.tmp"
    rm "$name.tmp"
    echo -e "---- '$name' checked ---\n\n"
  done
}

if [[ $# -ne 2 ]]; then
    echo "Error:   Illegal number of parameters."
    echo "Usage:   ./scripts/run-shellcheck.sh <task-name> <version>"
    echo "Example: ./scripts/run-shellcheck.sh my-task 1.0.0"
    exit 1
fi

run_shellcheck_on_task_steps "$1" "$2"
