# (DEPRECATED) evidence-summarize v3.1.0

Summarizes evidences for the given applications.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

 - **deployment-delta-list-path**: Path to JSON list of application names in inventory
 - **target**: The target branch in the inventory repo.
 - **toolchain-crn**: The crn of the toolchain
 - **git-api-token-key** (Default: `git-token`) Github enterprise api token secret name
 - **inventory-url**: The url of the inventory git repository
 - **evidence-repo-url** The url to the evidence git repository
 - **include-cd-evidence**: (Default: `0`) If 1, summarize will include CD evidence too
 - **break-glass-key**: Key in the `break-glass-name` `ConfigMap` that holds the Break-Glass mode settings (Default: `'break_glass'`)
 - **break-glass-name**:  Name of the `ConfigMap` that holds Break-Glass mode settings (default: `'environment-properties'`)
 - **backend**: (Default: `git`) specify the source of the evidence summary (`git` or `cos`)
 - **cos-bucket-name**: (Default: `""`) Bucket name in your Cloud Object Storage instance, used as an Evidence Locker
 - **cos-endpoint**: (Default: `""`) Endpoint of your Cloud Object Storage instance, used as an Evidence Locker
 - **toolchain-apikey-secret-key**: (Default: `'ibmcloud-api-key'`)
 - **continuous-delivery-context-secret**: (Default: `'secure-properties'`)
 - **pipeline-debug**: (Default: `0`) pipeline-debug mode

#### Implicit

The following params comes from tekton annotations:

 - **PIPELINE_RUN_ID**: unique id of the pipeline run

#### Workspaces

 - **artifacts**: workspace to store artifacts
 - **secrets**: workspace to get the secret from

### Outputs

#### Results

 - **summary-path**: The path of the created evidence summary
 - **formatted-summary-path**: Path to the formatted, human-readable evidence summary
 - **deployment-ready**: `Yes` if no failures in evidence, `no` otherwise

### Usage

The evidence locker in the workspace should be already cloned before this task.

Example usage in a pipeline:

```yaml
- name: evidence-summarize-task
  taskRef:
    name: evidence-summarize
  workspaces:
    - name: artifacts
      workspace: artifacts
    - name: secrets
      workspace: secrets
  params:
    - name: deployment-delta-list-path
      value: "deployment-delta-list.json"
    - name: target
      value: prod_candidate
    - name: toolchain-crn
      value: "crn:v1:bluemix:public:toolchain:us-south:a/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:bbbbbbbb-cccc-dddd-eeee-ffffffffffff::"
    - name: evidence-repo-url
      value: $(params.evidence-repo-url)
    - name: inventory-url
      value: $(params.inventory-url)
    - name: pipeline-debug
      value: $(params.pipeline-debug)
```
