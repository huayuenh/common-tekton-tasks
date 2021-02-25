# toolchain-extract-value v1.0.0 (DEPRECATED)

This task is for extracting values from the desired config map with a given jq expression.
You have to provide a jq expression and the targeted config map's details.



### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```


### Inputs

#### Parameters

- **config-map-name**: (Default: `toolchain`) The name of the ConfigMap
- **config-map-key**: (Default: `toolchain.json`) The key of the ConfigMap
- **expression**: A valid jq expression which is used to search
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

## Usage

The task will save the desired value into a tekton task result.
Check out the example below, where we pass the result of the `extract-value` task to the `use-result-task` task.
In addition, you have to add the `extracted-value` param to the `use-result-task` task itself.

``` yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  params:
    - name: expression
      description: A valid jq expression which is used to search
  tasks:
    - name: extract-value
      taskRef:
        name: extract-value
      params:
        - name: expression
          value: $(params.expression)
    - name: use-result-task
      runAfter: [extract-value]
      taskRef:
        name: use-result-task
      params:
        - name: extracted-value
          value: "$(tasks.extract-value.results.extracted-value)"
```
``` yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: use-result-task
spec:
  params:
    - name: extracted-value
      description: The extracted value from the extract-value task
  steps:
- name: use-result-task
  command: ["/bin/bash", "-c"]
  args:
    - |
      echo "$(params.extracted-value)"
```
