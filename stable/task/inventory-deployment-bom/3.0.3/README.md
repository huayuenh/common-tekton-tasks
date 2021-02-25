# (DEPRECATED) inventory-deployment-bom v3.0.3

Create the [Deployment BOM](https://pages.github.ibm.com/CloudEngineering/system_architecture/devops/appendix.html#deployment-BOM) based on inventory records.
The created JSON is uploaded to the evidence locker as an artifact.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

 - **deployment-delta-list-path**: Path to JSON list of application names in inventory
 - **target-environment**: Target branch/environment in the inventory.
 - **inventory-repo-url**: (Default: `""`) The inventory repository URL
 - **inventory-integration**: (Default: `""`) The toolchain integration name of the inventory repository
 - **evidence-repo-url**: URL to the evidence git repo
 - **cos-bucket-name**: (Default: `""`) Bucket name in your Cloud Object Storage instance, used as an Evidence Locker
 - **cos-endpoint**: (Default: `""`) Endpoint of your Cloud Object Storage instance, used as an Evidence Locker
 - **git-api-token-key**: (Default: `"git-token"`) The name of the secret that contains the git token for api authentication.
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit

- **GIT_TOKEN**: GitHub access token from `/secrets`, accessed with the name provided in the parameter `git-api-token-key`
- **toolchain**: the toolchain information in JSON format, provided by the pipeline in a ConfigMap

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: use to retry specific parts of a task, which are not stable

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: workspace to get the runtime acquired secret from

### Outputs

#### Results

 - **deployment-bom-url**: URL of the deployment BOM json in the locker
 - **deployment-bom-path**: Path of the deployment BOM json on the workspace
 - **status**: The status based on exit-code

### Usage

In a pipeline with workspaces

```yaml

  - name: prod-inventory-deployment-bom
    runAfter:
      - prod-get-git-credentials
    taskRef:
      name: inventory-deployment-bom
    workspaces:
      - name: artifacts
        workspace: artifacts
      - name: secrets
        workspace: artifacts
    params:
      - name: deployment-delta-list-path
        value: $(tasks.prod-get-deployment-delta.results.deployment-delta-list-path)
      - name: target-environment
        value: prod_candidate
      - name: inventory-repo-url
        value: $(tasks.setup.results.inventory-url)
      - name: evidence-repo-url
        value: $(tasks.setup.results.evidence-locker-url)
      - name: pipeline-debug
        value: $(params.pipeline-debug)

```
