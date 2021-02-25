# servicenow-create-change-request v2.0.1 (DEPRECATED)

Create a Change Request in ServiceNow. Provide all fields for the CR as parameters, or provide a path to a JSON that has all the necessary data.

Example content for a CR JSON:

```json
{
  "type": "emergency",
  "assignedto": "jane.doe@ibm.com",
  "backoutplan": "rollback",
  "priority": "critical",
  "purpose": "bugfix",
  "description": "test description",
  "environment": "crn:v1:bluemix:public::ch-ctu-2::::",
  "impact": "bug",
  "system": "devopsinsights",
  "outageduration": "0 00:00:00",
  "plannedstart": "2020-10-05 14:48:00",
  "plannedend": "2020-10-05 14:49:00",
  "deploymentready": "yes",
}
```

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

 - **servicenow-api-url**: The ServiceNow API URL you wish to use (test or live)
 - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
 - **servicenow-api-token-secret-key**: (Default: `servicenow-api-token`) The ServiceNow API token secret name

 - **change-request-url**: direct url to the newly created change request without the change request id
 - **change-request-id**: (Default: `notAvailable`) optional ServiceNow Change Request ID to use in deployment

 - **cr-json-path**: (Default: `""`) Path of the JSON file on the workspace, containing all the required information for a CR

 - **servicenow-configuration-item**: (Default: `""`) The name of the service to be deployed as it is registered in ServiceNow
 - **servicenow-deployment-ready**: (Default: `yes`) Ready for deployment. Allowed values: `yes | no`, in case of `no` the CR will be unapproved, and set to request approval.
 - **servicenow-assigned-to**: validated user in ServiceNow
 - **servicenow-description**: Text field to explain change process
 - **servicenow-purpose**: Text field to explain purpose of change
 - **servicenow-impact**: Text field to explain change impact
 - **servicenow-backout-plan**: Text field to explain backout plan
 - **servicenow-region-id**: IBM Cloud short CRN, example: `ibm:ys1:us-south`
 - **servicenow-priority**: (Default: `Low`) Change priority. Allowed values are `Critical | High | Moderate | Low | Planning`
 - **servicenow-outage-duration**: Duration in days hours:mins:seconds. Example: `1 01:00:00`
 - **servicenow-type**: (Default: `standard`) Change type. Allowed values: `standard | emergency`
 - **servicenow-planned-start**: planned start time in UTC. Format is `2017-07-13 08:00:00`
 - **servicenow-planned-end**: planned end time in UTC. Format is `2017-07-13 08:00:00`
 - **retry-count**: (Default: `5`) retry count
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit

The following inputs are coming from `/secrets` volume:

 - **SERVICENOW_TOKEN**: the servicenow api token

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks

### Outputs

### Results

- **change-request-id**: The created ServiceNow Change Request ID
- **change-request-url**: The created ServiceNow Change Request URL
- **exit-code**: The exit code of the `script`
- **status**: Can be `success` or `failure` depending on the `exit-code`

### Usage

Example usage in a pipeline, with a provided CR JSON

``` yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: cd-pipeline
spec:
  params:
    - name: servicenow-api-url
    - name: pipeline-debug
    - name: change-request-url
    - name: cr-json-path

  workspaces:
    - name: dynamic-secrets
    - name: artifacts

  tasks:
    - name: pipeline-create-cr
      taskRef:
        name: servicenow-create-change-request
      workspaces:
        - name: dynamic-secrets
          workspace: dynamic-secrets
      params:
        - name: servicenow-api-url
          value: $(params.servicenow-api-url)
        - name: change-request-url
          value: $(params.change-request-url)
        - name: cr-json-path
          value: $(params.change-request-json-path)
        - name: pipeline-debug
          value: $(params.pipeline-debug)
```

For a full example see the pipeline for [the compliant-cd-pipeline template](https://github.ibm.com/one-pipeline/compliance-cd-toolchain)
