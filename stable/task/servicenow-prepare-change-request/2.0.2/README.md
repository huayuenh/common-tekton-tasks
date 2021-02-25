# (DEPRECATED) servicenow-prepare-change-request v2.0.2

Collects information necessary for a change request, and creates a JSON file that can be fed to the [servicenow-create-change-request](#servicenow-create-change-request) task.

Previously this logic was part of the [servicenow-create-change-request](#servicenow-create-change-request) task, but it was extracted as a standalone task.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

- **servicenow-configuration-item**:  The name of the service to be deployed as it is registered in ServiceNow
- **inventory-name**:  The name of the inventory entry.
- **inventory-target**:  Target branch in the inventory repo.
- **inventory-folder**:  The path to the inventory repository on the workspace.
- **inventory-repo-name**: The name of the inventory repository
- **inventory-repo-owner**: The owner of the inventory repository
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

```
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
