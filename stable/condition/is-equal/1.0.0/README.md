
# is-equal v1.0.0

This `Condition` recieves two values as parameters, and checks if they are equal or not.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

- **left**: (Required) The left value in the equation
- **right**: (Required) The right value in the equation

## Usage

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  tasks:
    - name: this-task-will-not-run
      conditions:
        - conditionRef: util-is-equal
          params:
            - name: left
              value: "0"
            - name: right
              value: "1"
      taskRef:
        name: my-task

    - name: this-task-will-run
      conditions:
        - conditionRef: util-is-equal
          params:
            - name: left
              value: "1"
            - name: right
              value: "1"
      taskRef:
        name: my-task
```
