# servicenow-close-change-request v1.0.2 (DEPRECATED)

Close the Change Request in ServiceNow. This task relies on the output of the `servicenow-create-change-request` task.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

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
