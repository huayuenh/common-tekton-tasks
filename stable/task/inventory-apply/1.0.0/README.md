# (DEPRECATED) inventory-apply v1.0.0
Merges inventory changes from the change request branch into master

### Inputs

#### Parameters

 - **change-request-id**: unique servicenow change request id.
 - **inventory-folder**: directory name where the inventory located
 - **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit
  - **GIT_TOKEN**: GitHub access token from `/secrets`

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: use to retry specific parts of a task, which are not stable

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: workspace to get the secret from

### Usage
Pipeline with workspaces

```yaml
- name: pipeline-inventory-apply
  taskRef:
    name: inventory-apply
  runAfter:
    - pipeline-deployment
  workspaces:
    - name: artifacts
      workspace: artifacts
  params:
    - name: change-request-id
      value: $(tasks.pipeline-create-cr.results.change-request-id)
    - name: inventory-folder
      value: $(params.inventory-folder)
    - name: pipeline-debug
      value: $(params.pipeline-debug)
```
