# YAML
Tasks for lint the Tekton files.

#### Tasks
- [tekton-lint](#tekton-lint)

## (DEPRECATED) tekton-lint
This task uses the [tekton-linter](https://github.ibm.com/cocoa/tekton-lint) written by the CoCoA team.
The linter is responsible to enforce conventios, like naming, parameter usage etc.


**WARNING: This task needs to run on Kubernetes cluster with minimal version 1.15. If you are using your own Delivery Pipeline Private Worker to run your tekton pipeline(s), ensure your cluster is updated to this version at least.**

If using Git Statues URL this task requires git credentials in JSON file mounted to `/secrets/credentials/cred.json`
See [get-git-credentials](/preview/git/README.md) task.


### Inputs

#### Parameters

- **definitions**: Multiline list of entries where the linter should look for definitions to lint.
- **path**: Path to YAML, List of YAMLs or directory containing YAMLS to scan. When using directories all
sub directories are scanned. By default is will scan all YAMLs in your repo
- **statuses-url** (*Optional* Default: `""`) Set the github statues url to enable git status updates
- **status-context** (*Optional* Default: `"Tekton Linter"`) When using github statues customise the status context
- **status-pending-description** (*Optional* Default: `"Running Tekton Linter..."`) When using github statues customise the status pending description
- **status-success-description** (*Optional* Default: `"Tekton Linter Passed"`) When using github statues customise the status success description
- **status-fail-description** (*Optional* Default: `"Tekton Lint Failed"`) When using github statues customise the status failed description
- **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name, which is used as a key of a secret
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit

 - **GHE_TOKEN**: GitHub access token from `/secrets` workspace


#### Workspaces

 - **artifacts**: volume where the task looks for definitions
 - **secrets**: workspace to get the secret from

### Outputs

#### Results

- **exit-code**: The exit code of the `lint`
- **status**: Can be `success` or `failure` depending on the `exit-code`

## Usage

The task is **highly** dependent on the `GITHUB_TOKEN` environment variable, since it is not a parameter, please run the [get-git-credentials](/preview/git/README.md)


Get git credentials with [get-git-credentials](/preview/git/README.md)
Run task and update git status. Clone using [clone-repo-task](https://github.com/open-toolchain/tekton-catalog/tree/master/git).


``` yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pr-pipeline
spec:
  params:
    - name: statuses-url
      description: the status url to update
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
    - name: secrets
  tasks:
    - name: get-git-credentials
      taskRef:
        name: get-git-credentials
      runAfter:
        - clone
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: repository
          value: $(params.repository)

    - name: clone
      taskRef:
        name: clone-repo-task
      runAfter:
        - get-git-credentials
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: repository
          value: $(params.repository)
        - name: branch
          value: $(params.branch)
        - name: revision
          value: $(params.revision)

    - name: tekton-linting
      taskRef:
        name: tekton-lint
      runAfter:
        - clone
      workspaces:
        - name: artifacts
          workspace: artifacts
        - name: secrets
          workspace: secrets
      params:
        - name: definitions
          value: |
            compliance-ci-toolchain/.pipeline/**/*.yaml
            common-tekton-tasks/preview/**/*.yaml
            common-tekton-tasks/preview/**/*.yml
        - name: statuses-url
          value: $(params.statuses-url)
```
