# Util
<Description of the set of tasks>

#### Tasks
- [util-run](#util-run)
- [util-evaluate-pipeline-results](#util-evaluate-pipeline-results)
- [util-is-equal](#util-is-equal)

#### ConfigMap
- [retry-command](#retry-command)

## util-run
This task executes a given script in the given workspace. To use this `Task`, add a `Workspace` to the `Task` in your `Pipeline` where you want the script to be executed.

### Inputs

#### Parameters

- **image-name**: (Default: `icr.io/continuous-delivery/pipeline/pipeline-base-image:2.6@sha256:7f588468622a981f89cf5e1212aaf75fface9da6169b5345ca52ab63d8215907`) The name of the image where the script will be executed
- **script**: A shell script to execute.
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode


### Outputs

#### Results

- **exit-code**: The exit code of the `script`
- **status**: Can be `success` or `failure` depending on the `exit-code`


### Usage

The task will save the `exit-code` and `status` values into a tekton task result.
Check out the example below, where we pass the result of the `util-run` task to the `use-result-task` task.
In addition, you have to add the `exit-code` and `status` params to the `use-result-task` task itself.

``` yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  params:
    - name: pipeline-debug
      description: toggles debug mode for the pipeline

  workspaces:
    - name: scripts

  tasks:
    - name: util-run
      taskRef:
        name: util-run
      workspaces:
        - name: scripts
          workspace: scripts
      params:
        - name: script
          value: "#!/bin/sh\n%s\n exit 1"
        - name: pipeline-debug
          value: $(params.pipeline-debug)

    - name: use-result-task
      runAfter: [util-run]
      taskRef:
        name: use-result-task
      params:
        - name: exit-code
          value: "$(tasks.util-run.results.exit-code)"
        - name: status
          value: "$(tasks.util-run.results.status)"
```

## (DEPRECATED) util-evaluate-pipeline-results

This Task recieves a JSON Array containing the name, the expected result value and the actual result value as a parameter and checks if every result has the expected value or not. If not, the error is logged and exits with exit code 1.

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

## (DEPRECATED) util-is-equal

This `Condition` recieves two values as parameters, and checks if they are equal or not.

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

## (DEPRECATED) retry-command
This ConfigMap can be used to retry specific parts of a task, which are not that stable. The `retry-command.sh` script needs to be sourced before using the `retry` command.

### Inputs

#### Parameters
 - **retry-count**: retry count of tries
 - **retry-delay**: the amount of seconds between the retries


### Usage

#### Used with a function

```bash
  sample_function() {
    echo "first line"
    echo "second line"
    echo "third line"
  }

  retry $(params.retry-count) $(params.retry-delay) sample_function
```

#### Used with a command

```bash
  retry $(params.retry-count) $(params.retry-delay) ibmcloud login -a $IBMCLOUD_API -r $TOOLCHAIN_REGION --apikey $API_KEY
```

or

```bash
  retry $(params.retry-count) $(params.retry-delay) \
    ibmcloud login -a $IBMCLOUD_API -r $TOOLCHAIN_REGION --apikey $API_KEY
```

#### Used with error message
`retry` returns an exit value without terminating the pipeline, which can be used to follow the `retry` with an applicable error message

```bash
  retry 3 3 failing_command

  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    echo "Error happened!"
    exit $exit_code
  fi
```

#### Used in a task

```yaml
  ...

  steps:
    - name: sample-step
      image: sample-image
      script: |
        source /scripts/retry_command.sh

        retry $(params.retry-count) $(params.retry-delay) sample_command

        exit_code=$?

        if [ $exit_code -ne 0 ]; then
          echo "Error happened!"
          exit $exit_code
        fi

      volumeMounts:
        - mountPath: /scripts
          name: retry-command

  volumes:
    - name: retry-command
      configMap:
        name: retry-command
        items:
          - key: retry_command.sh
            path: retry_command.sh
```
