# servicenow-change-state-to-implement v1.0.0

Uses the [`cocoa` CLI](https://github.ibm.com/cocoa/scripts) to change the Change Request state to Implement in ServiceNow.

### Inputs

#### Parameters
 - **servicenow-api-url**: The ServiceNow API URL you wish to use (test or live)
 - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
 - **servicenow-api-token-secret-key**: (Default: `servicenow-api-token`) the servicenow api key from secrets
 - **change-request-id**: ID of the current Change Request
 - **retry-count**: (Default: `5`) retry count
 - **retry-delay**: (Default: `5`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

### Outputs

### Results

- **exit-code**: The exit code of the `script`
- **status**: `success` if `exit-code` is 0, otherwise will stop pipeline run if the CR state couldn't be changed to `implement`

### Usage

``` yaml
- name: change-state-to-implement
  taskRef:
    name: servicenow-change-state-to-implement
  params:
    - name: servicenow-api-url
      value: "https://watsontest.service-now.com"
    - name: change-request-id
      value: "CHG123456"
    - name: pipeline-debug
      value: 1
```
