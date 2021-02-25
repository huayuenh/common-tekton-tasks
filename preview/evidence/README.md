# evidence
Tasks covering the evidence locker operations

#### Tasks
- [evidence-add](#evidence-add)
- [evidence-create-incident-issue](#evidence-create-incident-issue)
- [evidence-format-summary](#evidence-format-summary)
- [evidence-summarize](#evidence-summarize)
- [evidence-upload-summary](#evidence-upload-summary)

## evidence-add
Adds a new evidence to the evidence locker repository. The evidence will be stored in the given workspace as well as in the evidence locker repository, which should be set up before this task run.

### Inputs

#### Parameters

 - **evidence-repo-url**: url to the evidence repo
 - **namespace**: pipeline namespace where the source of the evidence run ("ci or "cd")
 - **evidence-name**: name of the evidence
 - **evidence-type**: scheme type of the evidence
 - **evidence-type-version**: version number of the evidence type
 - **result**: result of the evidence ("success" or "failure")
 - **issues**: issue urls related to the evidence in an array
 - **artifacts**: an array of the artifacts
 - **task-step-name**: (Default: `""`) The exact step name in the pipeline task. Used to set up the exact URL to the taskRun
 - **toolchain-crn**: (Default: `null`) cloud resource name of the toolchain the pipeline belongs to
 - **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `0`) pipeline debug switch to enable extensive debugging
 - **git-api-token-key**: (Default: `git-token`) The name of the secret that contains the git token for api authentication.

#### Implicit

The following params comes from tekton annotations:

 - **PIPELINE_ID**: unique id of the pipeline
 - **PIPELINE_RUN_ID**: unique id of the pipeline run
 - **PIPELINE_RUN_URL**: url to the given pipeline run

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

  - **evidence-locker**: workspace to store the evidences
  - **secrets**: The workspace where we store the secrets

### Usage

The evidence locker in the workspace should be already cloned before this task.

Example usage in a pipeline:

```yaml
- name: evidence-add-task
  taskRef:
    name: evidence-add
  workspaces:
    - name: evidence-locker
      workspace: evidence-locker
  params:
    - name: evidence-repo-url
      value: $(params.evidence-repo-url)
    - name: namespace
      value: "ci"
    - name: evidence-name
      value: "unit-test-evidence"
    - name: evidence-type
      value: "test"
    - name: evidence-type-version
      value: "1.0"
    - name: result
      value: $(tasks.run-unit-tests.results.status)
    - name: issues
      value: |
        "$(tasks.unit-test-task.result.issue_url)"
        "$(tasks.integration-test-task.result.issue_url)"
    - name: pipeline-debug
      value: $(params.pipeline-debug)
```


## (DEPRECATED) evidence-create-incident-issue
The task clones the incident-script first, and executes it if the value of `result-status` is `failed`. The incident script will generate or update an issue in the incident issue repository with the given `commit-hash`, the `pipeline-run-url` and the `task-name`

### Inputs

#### Parameters

 - **secret-name**: The name of the secret in the workspace
 - **repository**: The git repo url
 - **incident-issue-repo**: The incident issue git repository
 - **incident-issue-integration**: The toolchain integration name of the incident issue repository
 - **task-name**: The name of the examined task
 - **result-status**: Passed or failed status from another task
 - **commit-hash**: The commit hash
 - **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `5`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `"0"`) pipeline debug switch

#### Implicit

 - **PIPELINE_RUN_URL**: url to the given pipeline run (comes from tekton annotation)
 - **TOKEN**: GitHub access token from the `secrets` workspace

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

  - **secrets**: workspace to get the secret from


### Outputs

#### Results

 - **issue-url**: The link to the created issue, can be an empty string if there was no issue created/updated

### Usage

Pipeline with a workspace which has a secret `github-token` in it and another task that uses the result of this task.

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  params:
    - name: pipeline-debug
      description: toggles debug mode for the pipeline

  workspaces:
    - name: secrets
    - name: artifacts

  tasks:
    - name: create-incident-issue
      taskRef:
        name: evidence-create-incident-issue
      runAfter:
        - get-git-credentials
      workspaces:
        - name: artifacts
          workspace: artifacts
        - name: secrets
          workspace: secrets
      params:
        - name: repository
          value: $(params.repository)
        - name: secret-name
          value: ghe-token
        - name: incident-issue-repo
          value: $(params.incident-issues-url)
        - name: task-name
          value: "failing-task-name"
        - name: result-status
          value: "failed"
        - name: commit-hash
          value: "1234abcd"

    - name: get-generated-issue-url
      runAfter: [create-incident-issue]
      taskRef:
        name: get-generated-issue-url
      params:
        - name: issue-url
          value: "$(tasks.create-incident-issue.results.issue-url)"
```

## (DEPRECATED) evidence-format-summary
Formats the evidence summary into a human readable format, to be fed into the Change Request

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

## (DEPRECATED) evidence-summarize

Summarizes evidences under the given paths.

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


## (DEPRECATED) evidence-upload-summary
Push evidence summary to the evidence locker repository.

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
