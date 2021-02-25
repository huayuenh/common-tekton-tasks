# (DEPRECATED) inventory-cr-add v4.0.0

Prerequisite: `clone-inventory-repo` task needs to be ran before this task.
Adds a change request into the inventory repository with the currently deployed app based on the environment and region.

### Inputs

#### Parameters
 - **version**: version of the app
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **change-request-id**: unique servicenow change request id
 - **deployment-delta-list-path**: Path to JSON list of application names in inventory
 - **inventory-folder**: directory name where the inventory located
 - **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name
 - **target-environment**: The deployment target environment
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
- name: pipeline-inventory-cr-add
    taskRef:
      name: inventory-cr-add
    runAfter:
      - pipeline-create-cr
    workspaces:
      - name: artifacts
        workspace: artifacts
    params:
      - name: change-request-id
        value: $(tasks.pipeline-create-cr.results.change-request-id)
      - name: application
        value: $(params.application)
      - name: inventory-folder
        value: $(params.inventory-folder)
      - name: target-environment
        value: prod
      - name: deployment-delta-list-path
        value: $(tasks.prod-get-deployment-delta.results.deployment-delta-list-path)
      - name: pipeline-debug
        value: $(params.pipeline-debug)
      - name: version
        value: $(params.version)
```
