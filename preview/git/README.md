# git
Tasks for working with git

#### Tasks
- [git-get-credentials](#git-get-credentials)
- [git-clone](#git-clone)
- [git-clone-inventory-repo](#git-clone-inventory-repo)

## (DEPRECATED) git-get-credentials
Retrieves git credential from toolchain and stores it as a json file in the workspace. This can be used in later stages.

This task supports the following git providers:
 - GitHub Enterprise
 - Public GitHub
 - Bitbucket
 - GitLab
 - Hosted Git

### Inputs

#### ConfigMaps

- **retry-command**: from `preview/util/configmap-retry.yaml`
- **config-volume**: the `toolchain` ConfigMap provided by the Toolchain instance, containing the `toolchain.json`

#### Parameters

  - **repository**: The git repo url you wish to retrieve the credentials for
  - **ibmcloud-api**: (Default: `https://cloud.ibm.com`) ibmcloud api endpoint
  - **repository-integration**: (Default: `""`) the repository integration name, task will look for repo url under this name in `toolchain.json`
  - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name
  - **retry-count**: (Default: `"5"`) retry count to fetch git token
  - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries

#### Implicit

For this task to run you need a repository integration (GitHub Enterprise, Public GitHub, Bitbucket, GitLab, Hosted Git) in your toolchain in order to fetch the correpsonding credentials.

- **API_KEY**: IBM Cloud API key with access to the toolchain (comes from the `secrets` volume)

The following inputs are coming from the path `/config/toolchain.json`:

- **TOOLCHAIN_CONFIG**: The content of the `toolchain.json` file
- **TOOLCHAIN_REGION**: The region of the toolchain
- **TOOLCHAIN_ID**: The ID of the toolchain
- **REGION_ID**: The region ID of the toolchain
- **GIT_SERVICE_INSTANCE_ID**: The ID of the git service instance
- **GIT_SERVICE_TYPE**: The type of the git service
- **GIT_TOKEN_URL**: The url of the request to get a git token
- **GIT_TOKEN**: The git access token

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

- **retry_command.sh**: use to retry specific parts of a task, which are not stable

### Results

- **repository**: the git repo url with the .git suffix
- **git-auth-user**: git user depending on the service type user for authentication
- **repo-name**: the repository name, from the url

### Outputs

#### Implicit

- **GIT_TOKEN**: The git access token in the `secrets` workspace


#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: The workspace where we store the secrets

### Usage

Example usage in a pipeline, where YAMLLint uses the credentials
to update a git status

``` yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: credentials-pipeline
spec:
  params:
    - name: repository
      description: the git repo
    - name: statuses_url
      description: the status url to update
  workspaces:
    - name: artifacts
  tasks:
      - name: git-get-credentials
        taskRef:
          name: git-get-credentials
        workspaces:
          - name: artifacts
            workspace: artifacts
        params:
          - name: repository
            value: $(params.repository)
          - name: repository-integration
            value: $(params.repository-integration)

      - name: linting
        taskRef:
          name: yaml-lint
        runAfter:
          - git-get-credentials
        workspaces:
          - name: artifacts
            workspace: artifacts
        params:
          - name: statuses_url
            value: $(params.statuses_url)
```

For a full example see the pipeline for [this repository](/.tekton)

## (DEPRECATED) git-clone

Clones a git repo to the workspace

**Note:** If running in a CI Pipeline you do not want to just clone the PR's repository.
You need to merge the content of the PR with the origin you are going to be merging into.
In tools like Jenkins and Travis CI this is handled for us. I have provided the option to
specify the origin which if set will preform the merge. You can get the origin value from
the Pull Request event with `$(events.pull_request.base.ref)` in your trigger binding.
For an example see the pipeline for [this repository](/.tekton)

When an error occurs during cloning the repository with the given branch or commit, the credentials are hidden in the error message.

### Inputs

#### Parameters

- **repository**: The git repository url we are cloning
- **branch**: (Default: `"master"`) The git branch
- **origin**: (Default: `""`) The origin you wish to merge code with
- **revision**: (Default: `""`) The git revision/commit to clone empty to just use branch
- **directoryName**: (Default: `"."`) Name of the new directory to clone into on the workspace
- **git-user**: User to clone with. Leave blank to pickup the details from the workspace `/secrets/credentials/cred.json`
- **git-api-token-key**: (Default: `git-token`) The name of the secret that contains the git token for api authentication.
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit

- **GIT_TOKEN**: GitHub access token from `secrets` workspace

### Results:
- **git-url**: the git clone url
- **git-branch**: the git branch to be checked out
- **git-commit**: the latest commit of the cloned repo
- **directory-name**: the name of the folder where the repo was cloned

### Outputs
The repository should be cloned into the `artifacts` workspace

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: The workspace where we store the secrets


### Usage
TaskRun pull master with GIT Credentials passed in
```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: git-clone-run
spec:
  taskRef:
    name: git-clone
  workspaces:
    - name: artifacts
      workspace: artifacts
    - name: secrets
      workspace: secrets
  params:
    - name: repository
      value: https://github.ibm.com/one-pipeline/common-tekton-tasks
```

Pipeline pull revision from branch with [git-get-credentials](#git-get-credentials)
```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pr-pipeline
spec:
  params:
    - name: repository
      description: the git repo
    - name: branch
      description: the branch for the git repo
    - name: revision
      description: |
        the git revision/commit to update the git HEAD to.
        Default is to mean only use the branch
  workspaces:
    - name: artifacts
  tasks:
    - name: git-get-credentials
      taskRef:
        name: git-get-credentials
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: repository
          value: $(params.repository)

    - name: clone
      taskRef:
        name: git-clone
      runAfter:
        - git-get-credentials
      workspaces:
        - name: artifacts
          workspace: artifacts
        - name: secrets
          workspace: secrets
      params:
        - name: repository
          value: $(params.repository)
        - name: branch
          value: $(params.branch)
        - name: revision
          value: $(params.revision)
```
For a full example see the pipeline for [this repository](/.tekton)

## (DEPRECATED) git-clone-inventory-repo
This task is deprecated, going to be removed soon.
Use `git-clone` and `inventory-get` tasks for the same functionality.
Clones the given inventory repo and return the full image url from it

### Inputs

#### Parameters
  - **app-name**: (Default: `""`) App name to find in inventory. If omitted, the application repo name will be used if possible.
  - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
  - **git-auth-user**: (Default: `""`) GitHub authentication method or username
  - **retry-count**: (Default: `"5"`) retry count to get inventory
  - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
  - **git-api-token-key**: (Default: `git-token`) The name of the secret that contains the git token for api authentication.
  - **retry-count**: (Default: `"5"`) retry count to get inventory
  - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries

#### Implicit

- **INVENTORY_REPO**: The inventory repo URL from `toolchain.json` (mounted to `cd-config-volume`)
- **INVENTORY_FOLDER**: The inventory repository name from `toolchain.json` (mounted to `cd-config-volume`)
- **APPLICATION_REPO**: The application repository name from `toolchain.json` (mounted to `cd-config-volume`)
- **GIT_TOKEN**: GitHub access token from `secrets` workspace

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 -**retry_command.sh**: use to retry specific parts of a task, which are not stable

### Results

- **registry-url**: the image registry url
- **registry-namespace**: the image registry namespace
- **image-name**: the built docker image name
- **image-tag**: the docker image tag, containing the commit hash
- **inventory-folder**: the name of the folder on the pvc, where the inventory repo was cloned to
- **app-name**: App name in inventory.

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: The workspace where we store the secrets

### Usage

Pipeline with workspace [git-clone-inventory-repo](#git-clone-inventory-repo)

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pr-pipeline
spec:
  params:
    - name: git-auth-user
  workspaces:
    - name: artifacts
    - name: secrets
  tasks:
    - name: pipeline-git-clone-inventory-repo
      taskRef:
        name: git-clone-inventory-repo
      runAfter:
        - pipeline-clone-repo
      workspaces:
        - name: artifacts
          workspace: artifacts
        - name: secrets
          workspace: secrets
      params:
        - name: git-auth-user
          value: $(params.git-auth-user)
```
For a full example see the pipeline for [this repository](/.tekton)
