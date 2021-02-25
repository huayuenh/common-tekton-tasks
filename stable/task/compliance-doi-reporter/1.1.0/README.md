# compliance-doi-reporter v1.1.0 (DEPRECATED)

Task that accepts multiple results from preceding tasks, then converts and uploads them to Devops Insights as test results.

Using this task, you'll have a visual dashboard in DOI of your compliance results in your pipeline run.

### Inputs

#### ConfigMaps

- **compliance-helper-scripts**: from `./configmap-helper-scripts.yaml`
- **retry-command**: from `preview/util/configmap-retry.yaml`
- **cd-config-volume**: Provided by the pipeline, containing the `toolchain.json`

#### Parameters

- **data**: Task results from the pipeline in a JSON format, see the Usage section below
- **app-name**: Logical application name for DevOps Insights
- **environment**: (Default: `""`) The environment name to associate with the test results. This option is ignored for unit tests, code coverage tests, and static security scans.
- **build-number**: Devops Inisghts build number reference. Default to the CD Tekton Pipeline build number
- **toolchain-id**: Toolchain service instance id - Default to the toolchain containing the CD Tekton PipelineRun currently executed
- **ibmcloud-api-key-secret-key**: (Default: `"ibmcloud-api-key"`) The IBM Cloud API key's secret name
- **continuous-delivery-context-secret**: (Default: `"secure-properties"`) Reference name for the secret resource
- **ibmcloud-api**: (Default: `"https://cloud.ibm.com"`) the IBM Cloud API URL
- **pipeline-debug**: (Default: `"0"`) pipeline debug switch to enable extensive debugging
- **retry-count**: (Default: `"5"`) retry count to pull and push to the DOI instance(?)
- **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
- **break-glass-key** (optional): Key in the `break-glass-name` `ConfigMap` that holds the Break-Glass mode settings (default: `'break_glass'`)
- **break-glass-name** (optional): Name of the `ConfigMap` that holds Break-Glass mode settings (default: `'environment-properties'`)

#### Implicit

 - **PIPELINE_ID**: unique id of the pipeline
 - **PIPELINE_RUN_ID**: unique id of the pipeline run
 - **PIPELINE_RUN_URL**: url to the given pipeline run
 - **DEFAULT_BUILD_NUMBER**: build number provided by the pipeline run

#### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks

## Usage

The `data` parameter is a JSON formatted array of the following objects:

```json
{
  "name": "", //task name that produced the result
  "step": "", // step name in the task named above
  "evidence_type": "com.ibm.test-or-task-type", // type of test or scan
  "expected": "success", // expected result
  "actual": "", // output from the task that produced result
},
```

Example usage in a pipeline:

```yaml
- name: build-compliance-doi-reporter
  taskRef:
    name: compliance-doi-reporter
  workspaces:
    - name: artifacts
      workspace: artifacts
  params:
    - name: app-name
      value: "$(params.app-name)"
    - name: pipeline-debug
      value: $(params.pipeline-debug)
    - name: ibmcloud-api-key-secret-key
      value: "api-key"
    - name: data
      value: |
        [
          {
            "name": "code-detect-secrets",
            "step": "detect-secrets",
            "evidence_type": "com.ibm.detect_secrets",
            "expected": "success",
            "actual": "$(tasks.code-detect-secrets.results.status)"
          },
          {
            "name": "code-unit-tests",
            "step": "run-script",
            "evidence_type": "com.ibm.unit_test",
            "expected": "success",
            "actual": "$(tasks.code-unit-tests.results.status)"
          },
        ]
```
