# retry-command v1.0.0

This ConfigMap can be used to retry specific parts of a task, which are not that stable. The `retry-command.sh` script needs to be sourced before using the `retry` command.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

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
