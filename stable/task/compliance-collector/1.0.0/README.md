# (DEPRECATED) compliance-collector v1.0.0

Task to execute multiple jobs that are all related to compliance evidence collection form a pipeline run.
Because of the nature of the task, it is recommended to use this near the end of the pipeline.

Jobs executed in this task:

- create incident issues on task results if needed
- upload task artifacts
- fetch and upload pipeline logs (log including everything that precedes this task)
- create and upload compliance evidence

Previously these were separated tekton tasks, running after each test and check, but usage shown that these jobs are always executed together, so including all these jobs in a single task makes sense, and also shortens the pipeline.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### ConfigMaps

- **compliance-helper-scripts**: from `./configmap-helper-scripts.yaml`
- **retry-command**: from `preview/util/configmap-retry.yaml`
- **cd-config-volume**: Provided by the pipeline, containing the `toolchain.json`

#### Parameters

- **data**: Task results from the pipeline in a JSON format, see the Usage section below
- **namespace**: pipeline namespace where the source of the evidence run ("ci or "cd")
- **incident-issue-repo**: The incident issue git repository
- **evidence-repo-url**: URL to the evidence git repo
- **commit-hash**: The commit hash on which the current build runs
- **toolchain-crn**: Cloud resource name of the toolchain the pipeline belongs to
- **cos-bucket-name**: (Default: `""`) Bucket name in your Cloud Object Storage instance, used as an Evidence Locker
- **cos-endpoint**: (Default: `""`) Endpoint of your Cloud Object Storage instance, used as an Evidence Locker
- **toolchain-apikey-secret-key**: (Default: `"ibmcloud-api-key"`) The IBM Cloud API key's secret name
- **continuous-delivery-context-secret**: (Default: `"secure-properties"`) Reference name for the secret resource
- **git-api-token-key**: (Default: `"git-token"`) The name of the secret that contains the git token for api authentication.
- **pipeline-debug**: (Default: `"0"`) pipeline debug switch to enable extensive debugging
- **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
- **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
- **skip-pipeline-logs**: (Default: `"0"`) Skip pipeline data upload as artifact. Useful is this task is run more than once in a pipeline.

#### Secrets

- **secure-properties**: Secrets provided by the IBM Cloud pipeline, Secret resource name can be overwritten using the param `continuous-delivery-context-secret`

#### Implicit

 - **PIPELINE_ID**: unique id of the pipeline
 - **PIPELINE_RUN_ID**: unique id of the pipeline run
 - **PIPELINE_RUN_URL**: url to the given pipeline run

#### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks
- **secrets**: The workspace where we store runtime acquired secrets

### Usage

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

Example usage in a pipeline:

```yaml

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
      value: $(tasks.code-extract-issues-repo-url.results.extracted-value)
    - name: evidence-repo-url
      value: $(tasks.code-extract-evidence-repo-url.results.extracted-value)
    - name: commit-hash
      value: $(tasks.code-fetch-code.results.git-commit)
    - name: toolchain-crn
      value: $(tasks.code-extract-toolchain-crn.results.extracted-value)
    - name: pipeline-debug
      value: $(params.pipeline-debug)
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

