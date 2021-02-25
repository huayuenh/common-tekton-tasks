# inventory-get v1.0.0
Prerequisite: The inventory repository must be cloned to a workspace before using this task.
Outputs the value of a given property from the target branch of the inventory repository.
The output can be accessed via `results`: `$(tasks.<task-name>.results.value)`.

### Inputs

#### Parameters

 - **name**: The name of the inventory entry.
 - **target**: The target in the inventory repo.
 - **property**: The property to get from the target in the inventory.
 - **inventory-url**: The url of the inventory
 - **git-api-token-key**: (Default: `git-token`) Github Enterprise API token secret name.
 - **pipeline-debug**: (Default: `"0"`) Enables pipeline debug mode.
 - **allow-default-value**: (Default: `"false"`) Allow using a default fallback value if it fails to get data from inventory
 - **default-value**: (Default: `""`) The default data used as a fallback value if `allow-default-value` is set to `"true"`

#### Implicit

 - **GHE_TOKEN**: GitHub access token from `/secrets` workspace

#### Workspaces

 - **secrets**: workspace to get the secret from

### Usage

```yaml
- name: pipeline-get-build-number
  taskRef:
    name: inventory-get
  workspaces:
    - name: secrets
      workspace: artifacts
  params:
    - name: name
      value: "compliance-app"
    - name: property
      value: "build_number"
    - name: target
      value: "prod_candidate"
    - name: inventory-url
      value: "https://example/org/repo"

# Results: $(tasks.pipeline-get-build-number.results.value)

- name: pipeline-get-pipeline-run-id
  taskRef:
    name: inventory-get
  workspaces:
    - name: secrets
      workspace: artifacts
  params:
    - name: name
      value: "compliance-app"
    - name: property
      value: "pipeline_run_id"
    - name: target
      value: "prod_candidate"
    - name: inventory-url
      value: "https://example/org/repo"

# Results: $(tasks.pipeline-get-pipeline-run-id.results.value)
```
