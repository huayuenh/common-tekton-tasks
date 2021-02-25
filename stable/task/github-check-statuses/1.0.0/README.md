# github-check-statuses v1.0.0
Checks if the required github settings are set up, and required status checks have run and passed.

This task is using the [cocoa cli](https://github.ibm.com/cocoa/scripts)'s `check pull-request-status` command with the environment variables below. The command's documentation with an example `required-checks` can be found [here](https://github.ibm.com/cocoa/scripts#cocoa-check-pull-request-status).

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters
 - **target-branch**: target branch where the required statuses and settings are checks
 - **required-checks**: array of required checks to verify in github
 - **gh-org**: The Github Organization/User (owner of the repository).
 - **repository**: The name of the repository to check.
 - **git-commit**: Hash of the given commit
 - **git-api-token-key**: (Default: `git-token`) The name of the secret that contains the git token for api authentication.
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
 - **retry-count**: (Default: `5`) retry count to check status-checks on a commit
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries

#### Implicit

The following inputs are coming from tekton annotation:

  - **PIPELINE_RUN_ID**: id of the current pipeline run
  - **PIPELINE_RUN_URL**: url of the current pipeline run

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

-**retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

 - **secrets**: The workspace where we store the secrets

### Usage

Example usage in a pipeline.

``` yaml
    - name: check-github-statuses
      taskRef:
        name: github-check-statuses
      workspaces:
        name: secrets
        workspace: secrets
      params:
        - name: target-branch
          value: $(params.branch)
        - name: required-checks
          value: |
          [{
            "type": "status",
            "name": "unit-test",
            "params": {
              "name": "tekton/ci-unit-tests"
            }
          }]
        - name: repository
          value: $(params.repository)
        - name: git-commit
          value: $(params.git-commit)
        - name: gh-org
          value: $(params.gh-org)
```
