# (DEPRECATED) evidence-summary-format v1.0.0

Formats the evidence summary into a human readable format, to be fed into the Change Request

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
 - **summary-path**: path to the evidence summary json file
 - **pipeline-debug**: pipeline-debug mode

#### Workspaces

 - **evidence-locker**: workspace to which contains the evidence locker repository

### Outputs

#### Results

 - **formatted-summary-path**: path to the plain text summary file

### Usage

```yaml
- name: prod-format-evidence-summary
  runAfter:
    - prod-summarize-evidence
  taskRef:
    name: evidence-format-summary
  workspaces:
    - name: evidence-locker
      workspace: artifacts
  params:
    - name: evidence-repo-path
      value: $(tasks.prod-get-evidence-locker-path.results.extracted-value)
    - name: pipeline-debug
      value: $(params.pipeline-debug)
    - name: summary-path
      value: $(tasks.prod-summarize-evidence.results.summary-path)
```
