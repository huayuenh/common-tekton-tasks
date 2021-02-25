
# `devops-insights-publish-build@v1.0.0` (DEPRECATED)



This task publishes a build record in DevOps Insights.


> :speech_balloon: If you have questions, go to [`#devops-compliance`](https://ibm-cloudplatform.slack.com/archives/CFQHG5PP1)!

## Parameters

- `app-name` (**required**): The app name of the build record.
- `git-branch` (**required**): The branch of the build record.
- `git-commit` (**required**): The commit hash of the build record.
- `git-repository` (**required**): The repository url of the build record.
- `api-endpoint` (optional): The IBM Cloud API endpoint. (default: `'https://cloud.ibm.com'`)
- `break-glass-key` (optional): Key in the `break-glass-name` `ConfigMap` that holds the Break-Glass mode settings (default: `'break_glass'`)
- `break-glass-name` (optional): Name of the `ConfigMap` that holds Break-Glass mode settings (default: `'environment-properties'`)
- `build-number` (optional): The build number of the build record in DevOps Insights. In case it's missing, the current build number will be used. (default: `''`)
- `build-status` (optional): The status (`pass` or `fail`). (default: `'pass'`)
- `job-url` (optional): The URL of the build job. In case it's missing, the current job URL will be used. (default: `''`)
- `pipeline-debug` (optional): Enable pipeline debug mode. (default: `'0'`)
- `secret-key` (optional): The key in `secret-name` which contains the IBM Cloud API Key. (default: `'toolchain-apikey'`)
- `secret-name` (optional): The name of the k8s `Secret` which contains the IBM Cloud API Key. (default: `'secure-properties'`)
- `toolchain-id` (optional): Toolchain ID where the DevOps Insights service is located. In case it's missing, the current toolchain will be used. (default: `''`)

## Results

This task emits no results.

## Dependencies

### Environment variables

> :bulb: This task sets up environment variables based on external k8s resources, so it might be required to make those resources available to the `Task`.

- `IBMCLOUD_API_KEY` is set to the value of `$(params.secret-key)` in the `Secret` named `$(params.secret-name)` (optional).
- `BREAK_GLASS` is set to the value of `$(params.break-glass-key)` in the `ConfigMap` named `$(params.break-glass-name)` (optional).
- `PIPELINE_RUN_URL` is set to the value of `metadata.annotations['devops.cloud.ibm.com/pipeline-run-url']`.
- `DEFAULT_BUILD_NUMBER` is set to the value of `metadata.annotations['devops.cloud.ibm.com/build-number']`.

### Volumes

> :bulb: This task mounts volumes based external k8s resources, so it might be required to make those resources available to the `Task`.

- `cd-config-volume` is a volume that mounts the `ConfigMap` named `toolchain` (**required**).

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
    - name: branch
    - name: repository
    - name: commit
  tasks:
    - name: publish-build
      taskRef:
        name: devops-insights-publish-build
      params:
        - name: app-name
          value: $(params.app-name)
        - name: git-repository
          value: $(params.repositorty)
        - name: git-branch
          value: $(params.branch)
        - name: git-commit
          value: $(params.commit)
```
