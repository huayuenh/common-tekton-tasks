# (DEPRECATED) inventory-conclude v1.0.0

Concludes deployment in inventory

### Inputs

#### Parameters

- **inventory-repo-url**: The url of the inventory git repository
- **target-environment**: Deployment target environment
 - **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit
  - **GIT_TOKEN**: GitHub access token from `/secrets`

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: use to retry specific parts of a task, which are not stable

#### Workspaces

 - **secrets**: workspace to get the secret from

### Usage
Pipeline with workspaces

```yaml
- name: pipeline-inventory-conclude
  taskRef:
    name: inventory-conclude
  runAfter:
    - pipeline-deployment
  workspaces:
    - name: secrets
      workspace: artifacts
  params:
    - name: inventory-repo-url
      value: $(params.inventory-url)
    - name: target-environment
      value: "staging"
    - name: pipeline-debug
      value: $(params.pipeline-debug)
```
