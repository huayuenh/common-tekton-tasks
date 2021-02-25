## containerize-check-va-scan v1.0.1 (DEPRECATED)

### Context - ConfigMap/Secret

  The task expects the following kubernetes resources to be defined:

  Secret containing:
  * **IBMCLOUD_API_KEY**: An [IBM Cloud Api Key](https://cloud.ibm.com/iam/apikeys) used to access to the IBM Cloud Container registry service.

### Parameters

* **image-url**: (optional) url of the image to VA scan - required if no image pipeline resource provided to this task
* **image-digest**: (optional) SHA id of the image to VA scan - required if no image pipeline resource provided and no `image-properties-file` value provided
* **image-properties-file**: file containing properties of the image to be scanned (default to 'build.properties')
* **max-iteration**: maximum number of iterations allowed while loop to check for va report (default to 30 iterations maximum)
* **sleep-time**: sleep time (in seconds) between invocation of ibmcloud cr va in the loop (default to 10 seconds between scan result inquiry)
* **scan-report-file**: (optional) filename for the scan report (json format) of the given image. It will be copied in the workspace
* **fail-on-scanned-issues**: flag (`true` | `false`) to indicate if the task should fail or continue if issues are found in the image scan result (default to 'true')
* **resource-group**: (optional) target resource group (name or id) for the ibmcloud login operation
* **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
* **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name
* **retry-count**: (Default: `5`) retry count to try ibmcloud commands
* **retry-delay**: (Default: `10`) the amount of seconds between the retries
* **break-glass-key**: (Default: `'break_glass'`) Key in the `break-glass-name` `ConfigMap` that holds the Break-Glass mode settings
* **break-glass-name**: (Default: `'environment-properties'`) Name of the `ConfigMap` that holds Break-Glass mode settings
* **pipeline-debug**: (Default: `0`) pipeline debug mode

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable\

### Results

* **scan-report-file**: the filename if the scan report for the image stored in the workspace
* **scan-status**: the status from Vulnerability Advisor - possible values: OK, WARN, FAIL, UNSUPPORTED, INCOMPLETE, UNSCANNED

### Workspaces

* **artifacts**: Workspace that may contain image information and will have the va report from the VA scan after this task execution

## Usages

```yaml
   - name: build-vulnerability-advisor
      taskRef:
        name: icr-check-va-scan
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: image-url
          value: "us.icr.io/bootcamp/app"
        - name: image-digest
          value: "sha256:1111111111111111"
        - name: scan-report-file
          value: 'app-image-va-report.json'
        - name: ibmcloud-api-key-secret-key
          value: "api-key"
        - name: fail-on-scanned-issues
          value: "false"
        - name: pipeline-debug
          value: $(params.pipeline-debug)
```
