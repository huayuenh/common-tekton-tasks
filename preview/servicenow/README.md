# ServiceNow Change management

Tasks for working with ServiceNow Change Management

#### Tasks

- [servicenow-prepare-change-request](#servicenow-prepare-change-request)
- [servicenow-create-change-request](#servicenow-create-change-request)
- [servicenow-check-change-request-approval](#servicenow-check-change-request-approval)
- [servicenow-close-change-request](#servicenow-close-change-request)
- [servicenow-change-state-to-implement](#servicenow-change-state-to-implement)



## (DEPRECATED) servicenow-prepare-change-request

Collects information necessary for a change request, and creates a JSON file that can be fed to the [servicenow-create-change-request](#servicenow-create-change-request) task.

Previously this logic was part of the [servicenow-create-change-request](#servicenow-create-change-request) task, but it was extracted as a standalone task.

### Inputs

#### Parameters

- **servicenow-configuration-item**:  The name of the service to be deployed as it is registered in ServiceNow
- **inventory-name**:  The name of the inventory entry.
- **inventory-target**:  Target branch in the inventory repo.
- **inventory-folder**:  The path to the inventory repository on the workspace.
- **registry-url**:  The registry url part of the image
- **registry-namespace**:  The registry name part of the image
- **image-name**:  The name of the given image
- **image-tag**: The tag part of the image
- **repository**:  The git repo of the application to be deployed
- **formatted-summary-path**: Path to the formatted evidence summary (Default: "")
- **evidence-failure-count**: Number of failures in the evidence summary - if it's higher than 0, the `deployment readiness` field in the CR will be marked as false (Default: "0")
- **cluster**:  The name or ID of the target production cluster. (Default: "")
- **cluster-region**:  The target region of production cluster. (Default: "")
- **cluster-namespace**: The namespace of target production cluster. (Default: "")
- **git-commit-from**:  git commit hash in the 'repository' to start reading changelog (Default: "")
- **git-commit-to**:  git commit hash in the 'repository' to stop reading changelog (Default: "")
- **emergency-label**: Label used for your Emergency releases, issues and PRs on GitHub (Default: "EMERGENCY")
- **change-request-id**:  optional ServiceNow Change Request ID (Default: "notAvailable")
- **continuous-delivery-context-secret**: Reference name for the secret resource (Default: "secure-properties")
- **ibmcloud-api-key-secret-key**:  The IBM Cloud api key secret name (Default: "ibmcloud-api-key")
- **git-api-token-key**:  github enterprise api token secret name (Default: "git-token")
- **ibmcloud-api**:  the ibmcloud api endpoint (Default: "https://cloud.ibm.com")
- **retry-count**:  retry count (Default: "5")
- **retry-delay**:  the amount of seconds between the retries (Default: "10")
- **pipeline-debug**:  Pipeline debug mode (Default: "0")

#### Implicit

The following inputs are coming from `/secrets` volume:

 - **IBMCLOUD_API_KEY**: the ibmcloud api token

The following inputs are coming from `/dynamic-secrets` workspace:

 - **GHE_TOKEN**: the GHE access token

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

 - **dynamic-secrets**: a workspace where the secrets obtained during pipeline run (`git-token`)
 - **artifacts**: The output volume to check out and store task scripts & data between tasks

### Outputs

#### Results

-  **change-request-json-path**: path to a JSON on the `artifacts` workspace, containing every necessary data for a Change Request

Example content of this JSON:

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


## (DEPRECATED) servicenow-create-change-request

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

## (DEPRECATED) servicenow-check-change-request-approval

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

## (DEPRECATED) servicenow-close-change-request

Close the Change Request in ServiceNow. This task relies on the output of the `servicenow-create-change-request` task.

### Inputs

#### Parameters

 - **close-category**: (Default: `"successful"`) Reason of closing the CR, possible values are `successful | successful_issues | unsuccessful | cancelled`
 - **close-notes**:  (Default: `""`) Text containing any kind of closing notes.
 - **close-category-script**: (Default: `""`) Script that provides close category type. If provided, the content of close-category will be ignored.
  * Supported shebangs by the default base-image:
    * Node: `#!/usr/bin/env node`
    * Python3: `#!/usr/bin/env python3`
    * Shell: `#!/bin/sh` (default - if you don't start your script with a shebang, Shell will be used - which is `dash` in the ubuntu base image)
    * Bash: `#!/bin/bash`
 - **close-notes-script**: (Default: `""`) Script that provides close notes. If provided, the content of close-notes will be ignored.
  * Supported shebangs by the default base-image:
    * Node: `#!/usr/bin/env node`
    * Python3: `#!/usr/bin/env python3`
    * Shell: `#!/bin/sh` (default - if you don't start your script with a shebang, Shell will be used - which is `dash` in the ubuntu base image)
    * Bash: `#!/bin/bash`
 - **servicenow-api-url**: The ServiceNow API URL you wish to use (test or live)
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
 - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
 - **servicenow-api-token-secret-key**: (Default: `servicenow-api-token`) The ServiceNow API token secret name
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
 - **artifacts**: The output volume to check out and store task scripts & data between tasks

#### Dependencies

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
    - name: pipeline-debug
    - name: continuous-delivery-context-secret
    - name: servicenow-api-token-secret-key
    - name: git-api-token-key
    - name: change-request-id

  workspaces:
    - name: dynamic-secrets


  tasks:


    - name: pipeline-create-cr
      taskRef:
        name: servicenow-create-change-request

      params:
        # see the params of servicenow-create-change-request above

    - name: pipeline-close-cr
      taskRef:
        name: servicenow-close-change-request
      runAfter:
        - pipeline-create-cr
      workspaces:
        - name: dynamic-secrets
          workspace: dynamic-secrets
      params:
        - name: close-category
          value: "successful"
        - name: close-notes
          value: "Deployed to kubernetes"
        - name: servicenow-api-url
          value: $(params.servicenow-api-url)
        - name: continuous-delivery-context-secret
          value: $(params.continuous-delivery-context-secret)
        - name: servicenow-api-token-secret-key
          value: $(params.servicenow-api-token-secret-key)
        - name: git-api-token-key
          value: $(params.git-api-token-key)
        - name: pipeline-debug
          value: $(params.pipeline-debug
        - name: change-request-id
          value: $(params.change-request-id)
```

For a full example see the pipeline for [the compliant-cd-pipeline template](https://github.ibm.com/one-pipeline/compliance-cd-toolchain)

## (DEPRECATED) servicenow-change-state-to-implement

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
