# (DEPRECATED) check-pull-request v1.0.0

Checks if all required checkboxes are checked in the pull request and if an issue is provided.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

 - **github-user**: github enterprise user
 - **git-api-token-key**: (Default: `git-token`) github enterprise api token secret name
 - **branch**: the feature branch
 - **target-branch**: the main branch
 - **pr-number**: the number of the pull request
 - **pipeline-debug**: (Default: `git-token`) enable pipeline debug mode
 - **directory-name**: directory where the repo being tested is clones
 - **to-commit**: the commit up to which commit messages are checked
 - **from-commit**: the commit from which commit messages are checked
 - **repo-url**: the url of the repo under test

#### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks
- **secrets**: The workspace where we store runtime acquired secrets

### Outputs

#### Results

- **exit-code**: The exit code of the task
- **status**: Can be `success` or `failure` depending on the `exit-code`

### Usage

The repo under test should be already cloned before this task.

Example usage in a pipeline:

```yaml
- name: pr-check
  runAfter:
    - tekton-lint
  taskRef:
    name: check-pull-request
  params:
    - name: branch
      value: $(params.branch)
    - name: target-branch
      value: $(params.target-branch)
    - name: pr-number
      value: $(params.pr-number)
    - name: github-user
      value: $(tasks.git-get-credentials.results.git-auth-user)
    - name: pipeline-debug
      value: $(params.pipeline-debug)
    - name: directory-name
      value: $(tasks.clone-repo.results.directory-name)
    - name: to-commit
      value: $(params.revision)
    - name: from-commit
      value: $(params.base-commit)
    - name: repo-url
      value: $(tasks.clone-repo.results.git-url)
  workspaces:
    - name: artifacts
      workspace: artifacts
    - name: secrets
      workspace: artifacts
```
