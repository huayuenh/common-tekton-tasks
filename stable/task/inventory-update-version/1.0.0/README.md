# (DEPRECATED) inventory-update-version v1.0.0

Creates a cr branch into the inventory repository with the proposed changes

### Inputs

#### Parameters

 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
 - **version**: the version of the application to be deployed
 - **artifact**: artifact that can be deployed according to this inventory update
 - **inventory-integration**: (Default: `inventory-repo`) the name of the inventory repo integration
 - **inventory-repo**: (Default: `""`) the inventory repository, in owner and repo name format
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
 - **repository**: application name to add to the change request
 - **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name
 - **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `"5"`) the amount of seconds between the retries

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
- name: inventory-update-version-task
  taskRef:
    name: inventory-update-version-task
  runAfter:
    - build-image
  workspaces:
    - name: artifacts
      workspace: artifacts
  params:
    - name: pipeline-debug
      value: $(params.pipeline-debug)
    - name: inventory-repo
      value: $(params.inventory-repo)
    - name: version
      value: $(params.version)
    - name: artifact
      value: $(tasks.build-image.results.image-url)
    - name: repository
      value: $(params.repository)
```
