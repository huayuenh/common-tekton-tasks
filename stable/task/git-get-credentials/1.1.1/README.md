# git-get-credentials v1.1.1

Retrieves git credential from toolchain and stores it as a json file in the workspace. This can be used in later stages.

This task supports the following git providers:
 - GitHub Enterprise
 - Public GitHub
 - Bitbucket
 - GitLab
 - Hosted Git

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

  - **repository**: The git repo url you wish to retrieve the credentials for
  - **ibmcloud-api**: (Default: `https://cloud.ibm.com`) ibmcloud api endpoint
  - **repository-integration**: (Default: `""`) the repository integration name, task will look for repo url under this name in `toolchain.json`
  - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
  - **git-api-token-key**: (Default: `git-token`) Name of the secret that contains the git api token.
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name
  - **retry-count**: (Default: `"5"`) retry count to fetch git token
  - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries

#### Implicit

For this task to run you need a repository integration (GitHub Enterprise, Public GitHub, Bitbucket, GitLab, Hosted Git) in your toolchain in order to fetch the correpsonding credentials.

You need to have a ConfigMap named toolchain, which contains a key called `toolchain.json`, which contains a JSON blob that we're using.

- **API_KEY**: IBM Cloud API key with access to the toolchain (comes from the `secrets` volume)
- **GIT_TOKEN**: (optional) Github access token (comes from the `secrets` volume), if this value is missing, task will get it using the provided `API_KEY`

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
    - name: secrets
  tasks:
      - name: git-get-credentials
        taskRef:
          name: git-get-credentials
        workspaces:
          - name: artifacts
            workspace: artifacts
          - name: secrets
            workspace: secrets
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
