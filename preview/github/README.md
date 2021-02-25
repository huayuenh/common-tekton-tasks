# Github

Tasks for interacting with Github.

#### Tasks
- [github-set-status](#github-set-status)
- [github-create-pull-request](#github-create-pull-request)

## (DEPRECATED) github-set-status
Sets a commit status in a given Github Repository. To use this `Task`, add a `Workspace` to the `Task` in your `Pipeline` which contains a Github API Token as a secret.

### Inputs

#### Parameters
 - **secret-name**: The name of the secret in the workspace (Required).
 - **repo-rul**: The URL of the Github repository (Required).
 - **commit-sha**: The commit hash value on which the status will be set (Required).
 - **state**: The commit state to set (pending, success, error, failure) (Required).
 - **task-name**: The task name in the pipeline which status we indicate. Used to set up context and the exact URL to the taskRun (Default: "")
 - **step-name**: The exact step name in the pipeline task which status we indicate. Used to set up the exact URL to the taskRun (Default: "")
 - **context**: This will be the 'name' of the state on the Github UI if `task-name` is empty (Default: `tekton`)
 - **prefix**: If `task-name` is provided, this will be the prefix to the task name, and used together as `context` (Default: 'tekton')
 - **description**: A description which will be displayed on the Github UI (Default: `Tekton CI Status`).
 - **target-url**: A target URL which will be displayed on the Github UI (Default: the URL of the current `PipelineRun`).
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **pipeline-debug**: Enable pipeline debug mode (Default: `"0"`).

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 -**retry_command.sh**: used to retry specific parts of a task, which are not stable

### Usage
Pipeline with a workspace which has a secret `github-token` in it.

This will set the status to success on the commit `ebfd2cab5145aaa7acd7d4f2a61e55649976818d` with the context `tekton/vulnerability-scan`. (Param `task-name` was provided, so it used that instead of the default context parameter)

```yaml
- name: github-set-status
  taskRef:
    name: set-status
  workspaces:
    - name: secrets
      workspace: your-workspace-name
  params:
    - name: secret-name
      value: github-token
    - name: repo-url
      value: https://github.ibm.com/repo-owner/repo-name
    - name: commit-sha
      value: ebfd2cab5145aaa7acd7d4f2a61e55649976818d
    - name: state
      value: success
    - name: task-name
      value: vulnerability-scan
    - name: pipeline-debug
      value: 1
```

## (DEPRECATED) github-create-pull-request
This task creates a pull request in a given repository on GitHub Enterprise. To use this `Task`, add a `Workspace` to the `Task` in your `Pipeline` which contains a Github API Token as a secret.

### Inputs

#### Parameters
 - **owner**: Required. The owner of the repository. (string)
 - **repository**: Required. The name of the repository. (string)
 - **head**: Required. The name of the branch where your changes are implemented. For cross-repository pull requests in the same network, namespace head with a user like this: username:branch. (string)
 - **base**: Required. The name of the branch you want the changes pulled into. This should be an existing branch on the current repository. You cannot submit a pull request to one repository that requests a merge to a base of another repository. (string)
 - **title**: Required. The title of the new pull request. (string)
 - **body**: The contents of the pull request. (string)
 - **draft**: Indicates whether the pull request is a draft. (boolean, possible values: 0 - default / 1)
 - **maintainer-can-modify**: Indicates whether maintainers can modify the pull request. (boolean, possible values: 0 / 1 - default)
 - **git-api-token-key**: github enterprise api token secret name (Default: `git-token`)

### Usage
Pipeline with a workspace which has a secret `git-token` in it.

This `Task` will open a pull request to `master` branch from `feat/example-branch`.

```yaml
- name: create-pull-request
  taskRef:
    name: github-create-pull-request
  workspaces:
    - name: secrets
      workspace: artifacts
  params:
    - name: owner
      value: "your-username"
    - name: repository
      value: "your-repo-name"
    - name: head
      value: "feat/example-branch"
    - name: base
      value: "master"
    - name: title
      value: "Automated Build Promotion"
    - name: body
      value: "This Pull Request was created by a Tekton Task!"
```
