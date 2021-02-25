# (DEPRECATED) pipeline-evaluate v1.0.0

This Task recieves a JSON Array containing the name, the expected result value and the actual result value as a parameter and checks if every result has the expected value or not. If not, the error is logged and exits with exit code 1.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

- **results**: (Required) The JSON Array containing the results in the following format.

```json
[{
  "name": "result-name",
  "expected": "expected-value",
  "actual": "actual-value"
}]
```

### Usage

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  tasks:
    - name: task-with-result-1
      taskRef:
        name: task-with-result

    - name: task-with-result-2
      taskRef:
        name: task-with-result

    - name: pipeline-evaluator
      runAfter:
        - task-with-result
      taskRef:
        name: util-evaluate-pipeline-results
      params:
        - name: results
          value: |
            [
              {
                "name": "run-unit-tests",
                "expected": "success",
                "actual": "$(tasks.task-with-result-1.results.status)"
              },
              {
                "name": "task-with-result-2",
                "expected": "success",
                "actual": "$(tasks.task-with-result-2.results.status)"
              }
            ]
```
