#!/usr/bin/env bash
set -e -o pipefail

if [[ "$PIPELINE_DEBUG" == 1 ]]; then
  pwd
  env
  trap env EXIT
  set -x
fi

ERROR=0

shopt -s nullglob

report() {
  ERROR=1
  echo -e "\e[31mERROR\e[0m: ${file}: $1"
}

for folder in stable/*/*; do
  # grab the latest version
  file=$(find "$folder" -mindepth 2 -maxdepth 2 -name '*.yaml' ! -type l | sort -V -r | head -n 1)

  kind=$(echo "$file" | awk -F/ '{print $2}')
  resource=$(echo "$file" | awk -F/ '{print $3}')
  version=$(echo "$file" | awk -F/ '{print $4}')

  echo "Checking $file..."

  if [[ "$resource" != "$(basename "$file" .yaml)" ]]; then
    report "Invalid filename, should be $resource.yaml"
  fi

  if [[ "$(yq r -j "$file" | jq -j '.kind | ascii_downcase')" != "$kind" ]]; then
    report "Invalid kind, should be $kind"
  fi

  SEMVER_REGEX="^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(\\-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"
  if ! [[ "$version" =~ $SEMVER_REGEX ]]; then
    report "version $version should match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'"
  fi

  if [[ "$(yq r -j "$file" | jq -j '.metadata.labels["app.kubernetes.io/version"]')" != "$version" ]]; then
    report "Invalid version, should be $version"
  fi

  if [[ "$kind" == task ]]; then
    while read -r step; do
      IMAGE=$(echo "$step" | jq -r '.image')
      if [[ ! "$IMAGE" =~ ^.*:.*@sha256:[a-z0-9]{64}$ && ! "$IMAGE" =~ \$\( ]]; then
        report "$IMAGE: Image version must be specified using the image tag and digest (eg. python:3.8@sha256:abc123)"
      fi
    done < <(yq r -j "$file" | jq -c '.spec.steps[]')

    while read -r step; do
      cmd="$(echo "$step" | jq -r '.command[0]')"
      case "$cmd" in
        /bin/bash|/bin/sh)
          report "$(echo "$step" | jq -r .name): Use 'script' instead of 'command'"
          ;;
      esac
    done < <(yq r -j "$file" | jq -c '.spec.steps[]')
  fi
done

printf "\n\n"
for folder in stable/*/*; do
  file=$(find "$folder" -mindepth 2 -maxdepth 2 -name '*.yaml' ! -type l | sort -V -r | head -n 1)
  kind=$(echo "$file" | awk -F/ '{print $2}')

  printf "\n"
  if [[ "$kind" == task ]]; then
    echo -e "\e[34mShellcheck running on\e[0m: ${file}:"
    while read -r step; do
      name="$(echo "$step" | jq -r '.name')"
      script="$(echo "$step" | jq -r '.script')"
      echo "Step: $name"
      echo "$script" | shellcheck -f gcc - || true
    done < <(yq r -j "$file" | jq -c '.spec.steps[]')
  fi
done

printf "\n\n"
echo "Checking symlinks..."

scripts/setup-symlinks.sh check

exit "$ERROR"
