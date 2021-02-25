# (DEPRECATED) evidence-summary-upload v1.0.0

Push evidence summary to the evidence locker repository.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

 - **evidence-summary-path**: path to the evidence repo
 - **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
 - **pipeline-debug**: (Default: `"0"`) pipeline-debug mode

#### Implicit

The following params comes from tekton annotations:

 - **PIPELINE_RUN_ID**: unique id of the pipeline run

#### Workspaces

 - **evidence-locker**: workspace to which contains the evidence locker repository

### Usage

The evidence locker in the workspace should be already cloned before this task.
Task `evidence-summarize` should create the evidence prior to this Task.

Example usage in a pipeline:

```yaml
- name: push-summary
  taskRef:
    name: evidence-upload-summary
  workspaces:
    - name: evidence-locker
      workspace: evidence-locker
  params:
    - name: evidence-summary-path
      value: "$(tasks.evidence-summarize-task.results.summary-path)"
    - name: pipeline-debug
      value: $(params.pipeline-debug)
```
