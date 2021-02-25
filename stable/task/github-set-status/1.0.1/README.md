# github-set-status v1.0.1

Sets a commit status in a given Github Repository. To use this `Task`, add a `Workspace` to the `Task` in your `Pipeline` which contains a Github API Token as a secret.


### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

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
