# inventory
Tasks for working with the inventory

#### Tasks
- [inventory-apply](#inventory-apply)
- [inventory-update-version](#inventory-update-version)
- [inventory-cr-add](#inventory-cr-add)
- [inventory-get-pipeline-run-id](#inventory-get-pipeline-run-id)
- [inventory-get](#inventory-get)

## (DEPRECATED) inventory-apply
Merges inventory changes from the change request branch into master

### Inputs

#### Parameters

 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **change-request-id**: unique servicenow change request id.
 - **inventory-folder**: directory name where the inventory located
 - **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit
  - **GIT_TOKEN**: GitHub access token from `/secrets`

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: use to retry specific parts of a task, which are not stable

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: workspace to get the secret from

### Usage
Pipeline with workspaces

```yaml
- name: pipeline-inventory-apply
  taskRef:
    name: inventory-apply
  runAfter:
    - pipeline-deployment
  workspaces:
    - name: artifacts
      workspace: artifacts
  params:
    - name: change-request-id
      value: $(tasks.pipeline-create-cr.results.change-request-id)
    - name: inventory-folder
      value: $(params.inventory-folder)
    - name: pipeline-debug
      value: $(params.pipeline-debug)
```

## (DEPRECATED) inventory-update-version

Creates a cr branch into the inventory repository with the proposed changes

### Inputs

#### Parameters

 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
 - **version**: the version of the application to be deployed
 - **artifact**: artifact that can be deployed according to this inventory update
 - **inventory-integration**: (Default: `inventory-repo`) the name of the inventory repo integration
 - **inventory-repo**: (Default: `""`) the inventory repository, in owner and repo name format
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **repository**: application name to add to the change request
 - **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries

#### Implicit
  - **GIT_TOKEN**: GitHub access token from `/secrets`

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: use to retry specific parts of a task, which are not stable

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: workspace to get the secret from

### Usage

Pipeline with workspaces

```yaml
- name: inventory-update-version-task
  taskRef:
    name: inventory-update-version-task
  runAfter:
    - build-image
  workspaces:
    - name: artifacts
      workspace: artifacts
  params:
    - name: pipeline-debug
      value: $(params.pipeline-debug)
    - name: inventory-repo
      value: $(params.inventory-repo)
    - name: version
      value: $(params.version)
    - name: artifact
      value: $(tasks.build-image.results.image-url)
    - name: repository
      value: $(params.repository)
```

## (DEPRECATED) inventory-cr-add

Prerequisite: `clone-inventory-repo` task needs to be ran before this task.
Adds a change request into the inventory repository with the currently deployed app based on the environment and region.

### Inputs

#### Parameters
 - **version**: version of the app
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **change-request-id**: unique servicenow change request id
 - **application**: application name to add to the change request
 - **inventory-folder**: directory name where the inventory located
 - **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit
  - **GIT_TOKEN**: GitHub access token from `/secrets`

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: use to retry specific parts of a task, which are not stable

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: workspace to get the secret from

### Usage
Pipeline with workspaces

```yaml
- name: pipeline-inventory-cr-add
    taskRef:
      name: inventory-cr-add
    runAfter:
      - pipeline-create-cr
    workspaces:
      - name: artifacts
        workspace: artifacts
    params:
      - name: change-request-id
        value: $(tasks.pipeline-create-cr.results.change-request-id)
      - name: application
        value: $(params.application)
      - name: inventory-folder
        value: $(params.inventory-folder)
      - name: pipeline-debug
        value: $(params.pipeline-debug)
      - name: version
        value: $(params.version)
```

## (DEPRECATED) inventory-get-pipeline-run-id
Prerequisite: `clone-inventory-repo` task needs to be ran before this task.
Outputs the id of the pipeline-run which built the image for a given app and version.
The output can be reached through `results`: `$(tasks.<task-name>.results.pipeline-run-id)`.
This Task is deprecated, please use [`inventory-get`](#inventory-get) `Task` instead.

### Inputs

#### Parameters

 - **app-name**: the name of the app to be deployed
 - **version**: the version of the app to be deployed
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **inventory-folder**: directory name where the inventory located.
 - **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit

 - **GIT_TOKEN**: GitHub access token from `/secrets`

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: use to retry specific parts of a task, which are not stable

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: workspace to get the secret from

### Usage

```yaml
- name: pipeline-get-pipeline-run-id
  taskRef:
    name: inventory-get-pipeline-run-id
  workspaces:
    - name: artifacts
      workspace: artifacts
  params:
    - name: app-name
      value: "compliance-app"
    - name: version
      value: "v1"
    - name: inventory-folder
      value: $(params.inventory-folder)
    - name: pipeline-debug
      value: $(params.pipeline-debug)

# Results: $(tasks.pipeline-get-pipeline-run-id.results.pipeline-run-id)
```

## (DEPRECATED) inventory-get-build-number
Prerequisite: `clone-inventory-repo` task needs to be ran before this task.
Outputs the build number of the CI Pipeline which built the image for a given app and version.
The output can be accessed via `results`: `$(tasks.<task-name>.results.build-number)`.
This Task is deprecated, please use [`inventory-get`](#inventory-get) `Task` instead.

### Inputs

#### Parameters

 - **app-name**: the name of the app to be deployed
 - **target**: (Default: `prod_candidate`) Target branch in the inventory repo.
 - **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit

 - **GIT_TOKEN**: GitHub access token from `/secrets` workspace

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: workspace to get the secret from

### Usage

```yaml
- name: pipeline-get-build-number
  taskRef:
    name: inventory-get-build-number
  workspaces:
    - name: artifacts
      workspace: artifacts
  params:
    - name: app-name
      value: "compliance-app"
    - name: inventory-folder
      value: $(params.inventory-folder)
    - name: pipeline-debug
      value: $(params.pipeline-debug)

# Results: $(tasks.pipeline-get-build-number.results.build-number)
```

## (DEPRECATED) inventory-get
Prerequisite: The inventory repository must be cloned to a workspace before using this task.
Outputs the value of a given property from the target branch of the inventory repository.
The output can be accessed via `results`: `$(tasks.<task-name>.results.value)`.

### Inputs

#### Parameters

 - **name**: The name of the inventory entry.
 - **target**: The target in the inventory repo.
 - **property**: The property to get from the target in the inventory.
 - **inventory-folder**: The path to the inventory repository on the workspace.
 - **git-api-token-key**: (Default: `git-token`) Github Enterprise API token secret name.
 - **pipeline-debug**: (Default: `"0"`) Enables pipeline debug mode.
 - **allow-default-value**: (Default: `"false"`) Allow using a default fallback value if it fails to get data from inventory
 - **default-value**: (Default: `""`) The default data used as a fallback value if `allow-default-value` is set to `"true"`

#### Implicit

 - **GIT_TOKEN**: GitHub access token from `/secrets` workspace

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: workspace to get the secret from

### Usage

```yaml
- name: pipeline-get-build-number
  taskRef:
    name: inventory-get
  workspaces:
    - name: artifacts
      workspace: artifacts
    - name: secrets
      workspace: artifacts
  params:
    - name: name
      value: "compliance-app"
    - name: property
      value: "build_number"
    - name: target
      value: "prod_candidate"
    - name: inventory-folder
      value: "path/to/inventory/repository/on/workspace"

# Results: $(tasks.pipeline-get-build-number.results.value)

- name: pipeline-get-pipeline-run-id
  taskRef:
    name: inventory-get
  workspaces:
    - name: artifacts
      workspace: artifacts
    - name: secrets
      workspace: artifacts
  params:
    - name: name
      value: "compliance-app"
    - name: property
      value: "pipeline_run_id"
    - name: target
      value: "prod_candidate"
    - name: inventory-folder
      value: "path/to/inventory/repository/on/workspace"

# Results: $(tasks.pipeline-get-pipeline-run-id.results.value)
```

