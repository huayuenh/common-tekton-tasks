# evidence-summary-upload v2.1.0 (deprecated)

Push evidence summary to the evidence locker repository and to the evidence locker COS Bucket, if present.

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
 - **cos-bucket-name**: (Default: `""`) Bucket name in your Cloud Object Storage instance, used as an Evidence Locker
 - **cos-endpoint**: (Default: `""`) Endpoint of your Cloud Object Storage instance, used as an Evidence Locker
 - **toolchain-apikey-secret-key**: (Default: `"ibmcloud-api-key"`) The IBM Cloud API key's secret name
 - **continuous-delivery-context-secret**: (Default: `"secure-properties"`) Reference name for the secret resource
 - **pipeline-debug**: (Default: `"0"`) pipeline debug switch to enable extensive debugging
 - **break-glass-key** (optional): Key in the `break-glass-name` `ConfigMap` that holds the Break-Glass mode settings (default: `'break_glass'`)
 - **break-glass-name** (optional): Name of the `ConfigMap` that holds Break-Glass mode settings (default: `'environment-properties'`)

#### Secrets

- **secure-properties**: Secrets provided by the IBM Cloud pipeline, Secret resource name can be overwritten using the param `continuous-delivery-context-secret`

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
# Without uploading to COS
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

# With uploading to COS
- name: evidence-summary-upload
  taskRef:
    name: evidence-upload-summary
  workspaces:
    - name: evidence-locker
      workspace: evidence-locker
  params:
    - name: cos-bucket-name
      value: "my-cos-bucket"
    - name: cos-endpoint
      value: "<insert-matching-cos-endpoint-here>"
    - name: evidence-repo-path
      value: $(tasks.prod-get-evidence-locker-path.results.extracted-value)
    - name: evidence-summary-path
      value: "$(tasks.prod-change-request-close-get-evidence-summary.results.summary-path)"
    - name: pipeline-debug
      value: $(params.pipeline-debug)
```
