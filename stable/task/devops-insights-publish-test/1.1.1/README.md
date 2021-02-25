
# `devops-insights-publish-test@v1.1.1` (DEPRECATED)



This task publishes a test record to DevOps Insights.


> :speech_balloon: If you have questions, go to [`#devops-compliance`](https://ibm-cloudplatform.slack.com/archives/CFQHG5PP1)!

## Parameters

- `app-name` (**required**): Logical application name for DevOps Insights
- `file-locations` (**required**): Semi-colon separated list of test result file locations
- `test-types` (**required**): Semi-colon separated list of test result types
- `break-glass-key` (optional): Key in the `break-glass-name` `ConfigMap` that holds the Break-Glass mode settings (default: `'break_glass'`)
- `break-glass-name` (optional): Name of the `ConfigMap` that holds Break-Glass mode settings (default: `'environment-properties'`)
- `build-number` (optional): Devops Inisghts build number reference. Default to the CD Tekton Pipeline build number (default: `''`)
- `continuous-delivery-context-secret` (optional): name of the configmap containing the continuous delivery pipeline context secrets (default: `'secure-properties'`)
- `environment` (optional): Optional, The environment name to associate with the test results. This option is ignored for unit tests, code coverage tests, and static security scans. (default: `''`)
- `doi-environment` (optional): Optional, The environment name to associate with the test results. This option is ignored for unit tests, code coverage tests, and static security scans. (default: `''`)
- `ibmcloud-api` (optional): the ibmcloud api (default: `'https://cloud.ibm.com'`)
- `pipeline-debug` (optional): Pipeline debug mode (default: `'0'`)
- `retry-count` (optional): retry count to pull and push git evidence repo (default: `'5'`)
- `retry-delay` (optional): the amount of seconds between the retries (default: `'10'`)
- `toolchain-apikey-secret-key` (optional): field in the secret that contains the api key used to access toolchain and DOI instance (default: `"ibmcloud-api-key"`)
- `toolchain-id` (optional): Toolchain service instance id - Default to the toolchain containing the CD Tekton PipelineRun currently executed (default: `''`)

## Results

This task emits no results.

## Dependencies

### Environment variables

> :bulb: This task sets up environment variables based on external k8s resources, so it might be required to make those resources available to the `Task`.

- `IBM_CLOUD_API_KEY` is set to the value of `$(params.toolchain-apikey-secret-key)` in the `Secret` named `$(params.continuous-delivery-context-secret)` (optional).
- `BREAK_GLASS` is set to the value of `$(params.break-glass-key)` in the `ConfigMap` named `$(params.break-glass-name)` (optional).
- `DEFAULT_BUILD_NUMBER` is set to the value of `metadata.annotations['devops.cloud.ibm.com/build-number']`.

### Volumes

> :bulb: This task mounts volumes based external k8s resources, so it might be required to make those resources available to the `Task`.

- `cd-config-volume` is a volume that mounts the `ConfigMap` named `toolchain` (**required**).
- `retry-command` is a volume that mounts the `ConfigMap` named `retry-command` (**required**).

## Usage

### [`pipeline.yaml`](samples/pipeline.yaml)

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  params:
    - name: app-name
    - name: file-locations
    - name: test-types
    - name: pipeline-debug
  tasks:
    - name: devops-insights-publish-test
      taskRef:
        name: devops-insights-publish-test
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: app-name
          value: "$(params.app-name)"
        - name: file-locations
          value: $(params.file-locations)
        - name: test-types
          value: $(params.test-types)
        - name: toolchain-apikey-secret-key
          value: "api-key"
        - name: pipeline-debug
          value: $(params.pipeline-debug)
```
