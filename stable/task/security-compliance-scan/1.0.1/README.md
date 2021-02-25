# Fortress Security Compliance Scan v1.0.1
Tasks Security Compliance Scan Service

#### Tasks

- [task-security-compliance-scan](#task-security-compliance-scan)

## task-security-compliance-scan
Checks the toolchain for an existing Security Compliance integration. Extracts data from the integration to
configure a request to initiate a scan from the Security & Compliances services

### Prerequisites
    Requires the toolchain to have a configured Security Compliance integration
### Inputs

#### ConfigMaps

- **retry-command**: from `preview/util/configmap-retry.yaml`
- **cd-config**: contains `toolchain.json`

#### Parameters

 - **pipeline-debug**: default 0. set to 1 to view extra logging for debugging
 - **integrations**: default "" empty. Populate to use custom integration data for processing the scan request
                    Task extracts data from current toolchain -> '.services[] | select (( .service_id=="security_compliance") and (.parameters.trigger_info))'
 - **retry-count**: (Default: `5`) retry count to check status-checks on a commit
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

-**retry_command.sh**: used to retry specific parts of a task. It this case it will attempt a retry in the event of failed cUrl requests.
The cUrl requests being used for authenticating and obtaining a bearer token and to initiate the security scan

Example usage in a pipeline.

``` yaml
    - name: security-compliance
      taskRef:
        name: security-compliance-scan
      params:
        - name: pipeline-debug
          value: $(params.pipeline-debug)
```
