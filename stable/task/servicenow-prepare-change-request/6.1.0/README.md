# servicenow-prepare-change-request v6.1.0 (DEPRECATED)

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

- **deployment-delta-list-path**: Path to JSON list of application names from inventory in the `artifacts` workspace
- **target-environment**: The deployment target environment
- **deployment-bom-path**:  The Deployment BOM JSON created by another task.
- **formatted-summary-path**: Path to the formatted evidence summary (Default: "")
- **servicenow-configuration-item**:  The name of the service to be deployed as it is registered in ServiceNow
- **omit-release-window**: do not add planned start and planned end to the cr JSON (`"true"|"false`, Default: "false")
- **inventory-repo**: The owner of the inventory repository
- **deployment-ready**: `yes|no` value, if it's `no`, the `deployment readiness` field in the CR will be marked as false (Default: `"yes"`)
- **cluster**:  The name or ID of the target production cluster. (Default: "")
- **cluster-region**:  The target region of production cluster. (Default: "")
- **cluster-namespace**: The namespace of target production cluster. (Default: "")
- **emergency-label**: Label used for your Emergency releases, issues and PRs on GitHub (Default: "EMERGENCY")
- **change-request-id**:  optional ServiceNow Change Request ID (Default: "notAvailable")
- **continuous-delivery-context-secret**: Reference name for the secret resource (Default: "secure-properties")
- **ibmcloud-api-key-secret-key**:  The IBM Cloud api key secret name (Default: "ibmcloud-api-key")
- **git-api-token-key**:  github enterprise api token secret name (Default: "git-token")
- **ibmcloud-api**:  the ibmcloud api endpoint (Default: "https://cloud.ibm.com")
- **retry-count**:  retry count (Default: "5")
- **retry-delay**:  the amount of seconds between the retries (Default: "10")
- **pipeline-debug**:  Pipeline debug mode (Default: "0")
- **break-glass-key**: Key in the `break-glass-name` `ConfigMap` that holds the Break-Glass mode settings (Default: `'break_glass'`)
- **break-glass-name**:  Name of the `ConfigMap` that holds Break-Glass mode settings (default: `'environment-properties'`)
- **break-glass-sn-region**:  Name of the `ConfigMap` that holds the ServiceNow region environment in Break-Glass mode (default: `'sn-region'`)

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

Note: `plannedstart` and `plannedend` only added if parameter `omit-release-window` is `"false"`
