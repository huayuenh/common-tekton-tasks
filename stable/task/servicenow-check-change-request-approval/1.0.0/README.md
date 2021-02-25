# servicenow-check-change-request-approval v1.0.0

Check the approval status of a Change Request in ServiceNow. This task relies on the output of the `servicenow-create-change-request` task.

### Inputs

#### Parameters
 - **servicenow-api-url**: The ServiceNow API URL you wish to use (test or live)
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
 - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
 - **servicenow-api-token-secret-key**: (Default: `servicenow-api-token`) the servicenow api key from secrets
 - **git-api-token-key**: (Default: `"git-token"`) github enterprise api token secret name
 - **change-request-id**: ID of the current Change Request
 - **retry-count**: (Default: `5`) retry count
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries

#### Implicit

The following inputs are coming from `/secrets` volume:

 - **SERVICENOW_TOKEN**: the servicenow api token

The following inputs are coming from `/dynamic-secrets` workspace:

 - **GHE_TOKEN**: the GHE access token

The following inputs are coming from tekton annotation:

 - **PIPELINE_RUN_ID**: ID of the current pipeline run

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

 - **dynamic-secrets**: a workspace where the secrets obtained during pipeline run (`git-token`)

### Outputs

### Results

- **exit-code**: The exit code of the `script`
- **status**: `success` if `exit-code` is 0, otherwise will stop pipeline run if the CR cannot be closed or not found

### Usage

Example usage in a pipeline, running after the `servicenow-create-change-request` task.

``` yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: cd-pipeline
spec:
  params:
    - name: servicenow-api-url
    - name: continuous-delivery-context-secret
    - name: servicenow-api-token-secret-key
    - name: git-api-token-key
    - name: pipeline-debug

  workspaces:
    - name: dynamic-secrets

  tasks:

    - name: pipeline-create-cr
      taskRef:
        name: servicenow-create-change-request

      params:
        # see the params of servicenow-create-change-request above

    - name: pipeline-check-cr-approval
      taskRef:
        name: servicenow-check-change-request-approval
      workspaces:
        - name: dynamic-secrets
          workspace: dynamic-secrets
      params:
        - name: servicenow-api-url
          value: $(params.servicenow-api-url)
        - name: continuous-delivery-context-secret
          value: $(params.continuous-delivery-context-secret)
        - name: servicenow-api-token-secret-key
          value: $(params.servicenow-api-token-secret-key)
        - name: git-api-token-key
          value: $(params.git-api-token-key)
        - name: pipeline-debug
          value: $(params.pipeline-debug)
        - name: change-request-id
          value: $(tasks.pipeline-create-cr.results.change-request-id)
```

For a full example see the pipeline for [the compliant-cd-pipeline template](https://github.ibm.com/one-pipeline/compliance-cd-toolchain)
