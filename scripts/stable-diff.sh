#!/usr/bin/env bash

task=$1
from=$2
to=$3
file=$4

if [ -z $task ]; then
  echo "
    usage: scripts/stable-diff.sh task_path from_version to_version [ filename ]

    Examples

    - Diff from 4.0.0 to 5.0.0 in stable/task/servicenow-prepare-change-request:

      scripts/stable-diff.sh stable/task/servicenow-prepare-change-request 4.0.0 5.0.0

    - Diff the README between 4.0.0 and 5.0.0 of stable/task/servicenow-prepare-change-request:

      scripts/stable-diff.sh stable/task/servicenow-prepare-change-request 4.0.0 5.0.0 README.md
  "

  exit 1
fi

task_name="$(echo -n $task | awk -F "/" '{print $3}')"

if [ -z $file ]; then
  git diff master:$task/$from/$task_name.yaml $task/$to/$task_name.yaml
else
  git diff master:$task/$from/$file $task/$to/$file
fi

