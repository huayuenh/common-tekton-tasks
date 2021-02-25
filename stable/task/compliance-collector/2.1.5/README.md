# `compliance-collector@v2.1.5`

Task to execute multiple jobs that are all related to compliance evidence collection from a pipeline run.
Because of the nature of the task, it is recommended to use this near the end of the pipeline.

Jobs executed in this task:

- create incident issues on task results if needed
- upload task artifacts
- fetch and upload pipeline logs (log including everything that precedes this task)
- create and upload compliance evidence

Previously these were separated tekton tasks, running after each test and check, but usage shown that these jobs are always executed together, so including all these jobs in a single task makes sense, and also shortens the pipeline.

The `data` parameter is a JSON formatted array of the following objects:

```json
{
  "name": "", //task name that produced the result
  "step": "", // step name in the task named above
  "evidence_type": "com.ibm.test-or-task-type", // type of test or scan that will appear in compliance reports
  "evidence_type_version": "1.0.0", // version of evidence type
  "expected": "success", // expected result
  "actual": "", // output from the task that produced result
  "artifacts": [
    "", // paths of generated artifacts, scans test results...
  ]
},
```

> :speech_balloon: If you have questions, go to [`#devops-compliance`](https://ibm-cloudplatform.slack.com/archives/CFQHG5PP1)!

## Parameters

- `application-repo-url` (optional): URL to the application git repo
- `commit-hash` (optional): The commit hash on which the current build runs
- `data` (**required**): Task results from the pipeline in a JSON format, see the documentation for more details
- `evidence-repo-url` (**required**): URL to the evidence git repo
- `incident-issue-repo` (**required**): The incident issue git repository
- `namespace` (**required**): Pipeline namespace where the source of the evidence run ("ci or "cd")
- `toolchain-crn` (**required**): Cloud resource name of the toolchain the pipeline belongs to
- `break-glass-key` (optional): Key in the `break-glass-name` `ConfigMap` that holds the Break-Glass mode settings (default: `'break_glass'`)
- `break-glass-name` (optional): Name of the `ConfigMap` that holds Break-Glass mode settings (default: `'environment-properties'`)
- `continuous-delivery-context-secret` (optional): undefined (default: `'secure-properties'`)
- `cos-bucket-name` (optional): Bucket name in your Cloud Object Storage instance, used as an Evidence Locker (default: `''`)
- `cos-endpoint` (optional): Endpoint of your Cloud Object Storage instance, used as an Evidence Locker (default: `''`)
- `git-api-token-key` (optional): undefined (default: `'git-token'`)
- `pipeline-debug` (optional): Pipeline debug mode (default: `'0'`)
- `retry-count` (optional): retry count to pull and push git evidence repo (default: `'5'`)
- `retry-delay` (optional): the amount of seconds between the retries (default: `'5'`)
- `skip-pipeline-logs` (optional): Skip pipeline data upload as artifact. Useful if this task is run more than once in a pipeline. (default: `'0'`)
- `toolchain-apikey-secret-key` (optional): undefined (default: `'ibmcloud-api-key'`)

## Workspaces

- `artifacts`: N/A
- `secrets`: N/A

## Results

This task emits no results.

## Dependencies

### Environment variables

> :bulb: This task sets up environment variables based on external k8s resources, so it might be required to make those resources available to the `Task`.

- `BREAK_GLASS` is set to the value of `$(params.break-glass-key)` in the `ConfigMap` named `$(params.break-glass-name)` (optional).
- `PIPELINE_ID` is set to the value of `metadata.annotations['devops.cloud.ibm.com/pipeline-id']`.
- `PIPELINE_RUN_ID` is set to the value of `metadata.annotations['devops.cloud.ibm.com/tekton-pipeline']`.
- `PIPELINE_RUN_URL` is set to the value of `metadata.annotations['devops.cloud.ibm.com/pipeline-run-url']`.

### Volumes

> :bulb: This task mounts volumes based external k8s resources, so it might be required to make those resources available to the `Task`.

- `retry-command` is a volume that mounts the `ConfigMap` named `retry-command` (**required**).
- `compliance-helper-scripts` is a volume that mounts the `ConfigMap` named `compliance-helper-scripts` (**required**).
- `cd-config-volume` is a volume that mounts the `ConfigMap` named `toolchain` (**required**).
- `secrets` is a volume that mounts the `Secret` named `$(params.continuous-delivery-context-secret)` (**required**).

## Usage

### [`pipeline.yaml`](samples/pipeline.yaml)

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pipeline
spec:
  params:
    - name: toolchain-id
    - name: commit-hash
    - name: evidence-repo-url
    - name: issue-repo-url
  workspaces:
    - name: artifacts
  tasks:
    - name: code-detect-secrets:
      taskRef:
        name: detect-secrets
    - name: code-unit-tests
      taskRef:
        name: unit-tests
    - name: build-compliance-collector
      taskRef:
        name: compliance-collector
      workspaces:
        - name: artifacts
          workspace: artifacts
        - name: secrets
          workspace: artifacts
      params:
        - name: namespace
          value: ci
        - name: incident-issue-repo
          value: $(params.issue-repo-url)
        - name: evidence-repo-url
          value: $(params.evidence-repo-url)
        - name: commit-hash
          value: $(params.commit-hash)
        - name: toolchain-crn
          value: $(params.toolchain-id)
        - name: toolchain-apikey-secret-key
          value: "api-key"
        - name: data
          value: |
            [
              {
                "name": "code-detect-secrets",
                "step": "detect-secrets",
                "evidence_type": "com.ibm.detect_secrets",
                "evidence_type_version": "1.0.0",
                "expected": "success",
                "actual": "$(tasks.code-detect-secrets.results.status)",
                "artifacts": [
                  "$(tasks.code-detect-secrets.results.artifact-path)"
                ]
              },
              {
                "name": "code-unit-tests",
                "step": "run-script",
                "evidence_type": "com.ibm.unit_test",
                "evidence_type_version": "1.0.0",
                "expected": "success",
                "actual": "$(tasks.code-unit-tests.results.status)",
                "artifacts": [
                  "$(tasks.code-unit-tests.results.artifact-path)"
                ]
              }
            ]
```
