# static-code-scan
Tasks for running the ASoC static scanner

#### Tasks
- [static-code-scan-asoc](#static-code-scan-asoc)

## static-code-scan-asoc
Runs the ASoC(AppScan on Cloud) scanner with the given repository to export issues and vulnerabilities.
The result of the task is a file named `static_code_scan_results.json`, in which the evidences are extracted.


### Inputs

#### Parameters
 - **appscan-scan-name**: ASoC application scan name
 - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
 - **appscan-key-secret-secret-key**: (Default: `appscan-key-secret`) ASoC secret key's secret name, comes from environment properties as pipeline secret
 - **appscan-key-id-secret-key**: (Default: `appscan-key-id`) ASoC secret key's secret, comes from environment properties as pipeline secret
 - **app-directory**: The path of the application inside the workspace `artifacts`
 - **scan-minutes-limit**: The scans limit in minutes (Default: `"10"`) (positive integer as string)
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode


### Output

## Results

 - **extracted-issues**: Path of the extracted issues in JSON format
 - **exit-code**: The exit code of the `script`
 - **status**: Can be `success` or `failure` depending on the `exit-code`


### Usage
Pipeline with task-pvc

```yaml
- name: pipeline-static-code-scan
  taskRef:
    name: asoc-static-code-scan-task
  runAfter:
    - unit-test
  params:
    - name: appscan-app-name
      value: $(params.appscan-app-name)
```

### ASoC keys and app identification

[Apply for HCL products](https://ibm.biz/ASoC_Onboarding) or lookup the #ciso-asoc slack channel.
Login/register in the [HCL site](https://cloud.appscan.com/AsoCUI/serviceui/login)

Create an application, this will be the **appscan-scan-name** you can follow [this guide](https://help.hcltechsw.com/appscan/ASoC/ASoC_Workflow.html)

For the **appscan-key-secret** and **appscan-key-id** visit the [settings site](https://cloud.appscan.com/AsoCUI/serviceui/main/admin/apiKey).


## Please keep that in mind, that
  - the scanner locks the files during the scan
  - the task is not responsible for installing the dependencies, please make sure there is a previous task to do that
  - the scanner can take a lot of time to run, because of the number of parallel scans are limited
  - the scan-limit-minutes variable is not the restriction for the task itself, but for the scan enqueuing only
