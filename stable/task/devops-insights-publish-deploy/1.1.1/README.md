
# `devops-insights-publish-deploy@v1.1.1` (DEPRECATED)



This task publishes a deploy record to DevOps Insights


> :speech_balloon: If you have questions, go to [`#devops-compliance`](https://ibm-cloudplatform.slack.com/archives/CFQHG5PP1)!

## Parameters

- `app-name` (**required**): Logical application name for DevOps Insights
- `environment` (**required, if no `doi-environment is set`**): The environment where the pipeline job deployed the app.
- `doi-environment` (**required, if no `environment is set`**): The environment set in the DOI settings.
- `app-url` (optional): The URL where the deployed app is running (default: `''`)
- `break-glass-key` (optional): Key in the `break-glass-name` `ConfigMap` that holds the Break-Glass mode settings (default: `'break_glass'`)
- `break-glass-name` (optional): Name of the `ConfigMap` that holds Break-Glass mode settings (default: `'environment-properties'`)
- `build-number` (optional): Devops Inisghts build number reference. Default to the CD Tekton Pipeline build number (default: `''`)
- `continuous-delivery-context-secret` (optional): name of the configmap containing the continuous delivery pipeline context secrets (default: `'secure-properties'`)
- `deploy-status` (optional): The deployment status (can be either pass | fail) (default: `'pass'`)
- `ibmcloud-api` (optional): the ibmcloud api (default: `'https://cloud.ibm.com'`)
- `job-url` (optional): The url to the job's deployment logs. Default to the CD Tekton PipelineRun currently executed (default: `''`)
- `pipeline-debug` (optional): Pipeline debug mode (default: `'0'`)
- `toolchain-apikey-secret-key` (optional): field in the secret that contains the api key used to access toolchain and DOI instance (default: `"ibmcloud-api-key"`)
- `toolchain-id` (optional): Toolchain service instance id - Default to the toolchain containing the CD Tekton PipelineRun currently executed (default: `''`)

## Results

This task emits no results.

## Dependencies

### Environment variables

> :bulb: This task sets up environment variables based on external k8s resources, so it might be required to make those resources available to the `Task`.

- `IBM_CLOUD_API_KEY` is set to the value of `$(params.toolchain-apikey-secret-key)` in the `Secret` named `$(params.continuous-delivery-context-secret)` (optional).
- `BREAK_GLASS` is set to the value of `$(params.break-glass-key)` in the `ConfigMap` named `$(params.break-glass-name)` (optional).
- `PIPELINE_RUN_URL` is set to the value of `metadata.annotations['devops.cloud.ibm.com/pipeline-run-url']`.
- `DEFAULT_BUILD_NUMBER` is set to the value of `metadata.annotations['devops.cloud.ibm.com/build-number']`.

### Volumes

> :bulb: This task mounts volumes based external k8s resources, so it might be required to make those resources available to the `Task`.

- `cd-config-volume` is a volume that mounts the `ConfigMap` named `toolchain` (**required**).

## Usage

### [`pipeline.yaml`](samples/pipeline.yaml)

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  params:
    - name: application
    - name: doi-toolchain-id
    - name: build-number
    - name: pipeline-debug
  tasks:
    - name: doi-publish-deployrecord
      taskRef:
        name: doi-publish-deployrecord
      params:
        - name: app-name
          value: "$(params.application)"
        - name: toolchain-id
          value: "$(params.doi-toolchain-id)"
        - name: build-number
          value: "$(params.build-number)"
        - name: environment
          value: "prod"
        - name: job-url
          value: "http://example.com"
        - name: app-url
          value: "http://example.com"
        - name: toolchain-apikey-secret-key
          value: "ibmcloud-api-key"
        - name: pipeline-debug
          value: "$(params.pipeline-debug)"
```
