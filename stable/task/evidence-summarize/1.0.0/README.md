# (DEPRECATED) evidence-summarize v1.0.0

Summarizes evidences under the given paths.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

 - **evidence-repo-path**: path to the evidence repo
 - **path-list**: list of paths under which the evidences can be found (separated by new line)
 - **toolchain-crn**: the crn of the toolchain
 - **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `0`) pipeline-debug mode

#### Implicit

The following params comes from tekton annotations:

 - **PIPELINE_RUN_ID**: unique id of the pipeline run

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

 - **evidence-locker**: workspace to which contains the evidence locker repository

### Outputs

#### Results

 - **summary-path**: The path of the created evidence summary
 - **failure-count**: Number of failures in evidence

### Usage

The evidence locker in the workspace should be already cloned before this task.

Example usage in a pipeline:

```yaml
- name: evidence-summarize-task
  taskRef:
    name: evidence-summarize
  workspaces:
    - name: evidence-locker
      workspace: evidence-locker
  params:
    - name: evidence-repo-path
      value: "evidence-locker-repo"
    - name: path-list
      value: |
        ci/pipeline-run-id-1
        cd/pipeline-run-id-2
    - name: toolchain-crn
      value: "crn:v1:bluemix:public:toolchain:us-south:a/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:bbbbbbbb-cccc-dddd-eeee-ffffffffffff::"
    - name: pipeline-debug
      value: $(params.pipeline-debug)
```
