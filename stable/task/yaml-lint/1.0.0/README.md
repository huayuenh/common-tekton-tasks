# yaml-lint v1.0.0

This task uses the Python `yamllint` package to lint YAML files. `yamllint` not only checks for syntax validity,
 but for weirdness's like key repetition and cosmetic problems such as lines length, trailing spaces, indentation, etc.
 A rules configuration can be provided if you want to customise the linter.

https://yamllint.readthedocs.io/en/stable/

**WARNING: This task needs to run on Kubernetes cluster with minimal version 1.15. If you are using your own Delivery Pipeline Private Worker to run your tekton pipeline(s), ensure your cluster is updated to this version at least.**

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

- **path**: Path to YAML, List of YAMLs or directory containing YAMLS to scan. When using directories all
sub directories are scanned. By default is will scan all YAMLs in your repo
- **rules**: Custom rules file to apply to the linter. If you provide the value "relaxed" it will use the default
 relaxed rule set. This is not needed if a rules config file with the name `.yamllint`, `.yamllint.yaml` or
 `.yamllint.yml` in the root of your repo. [See official documentation for how to configure the rules file](https://yamllint.readthedocs.io/en/stable/configuration.html)
- **strict-mode** (*Optional* Default: `"true"`) Set `--strict` mode
- **flags** Add additional flags that `yamllint` can accept here.
- **fail_task** (*Optional* Default: `"false"`) Set `true` or `false`, Fail task on linting failure when `true`
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Workspaces

 - **artifacts**: volume where the task looks for definitions

### Outputs

#### Results

- **exit-code**: The exit code of the `lint`
- **status**: Can be `success` or `failure` depending on the `exit-code`

These results can be used to set the Github status using this task: [github-set-status](https://github.ibm.com/one-pipeline/common-tekton-tasks/blob/master/preview/github/task-set-status.yaml).

See full YAMLLint documentation for more examples https://yamllint.readthedocs.io/en/stable/

## Usage

Clone using [clone-repo-task](https://github.com/open-toolchain/tekton-catalog/tree/master/git)

``` yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pr-pipeline
spec:
  params:
    - name: repository
      description: the git repo
    - name: branch
      description: the branch for the git repo
    - name: revision
      description: |
        the git revision/commit to update the git HEAD to.
        Default is to mean only use the branch
  workspaces:
    - name: artifacts
  tasks:
    - name: clone
      taskRef:
        name: clone-repo-task
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: repository
          value: $(params.repository)
        - name: branch
          value: $(params.branch)
        - name: revision
          value: $(params.revision)

    - name: linting
      taskRef:
        name: yaml-lint
      runAfter:
        - clone
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: rules
          value: "yamllint-rules.yaml"
        - name: fail_task
          value: "true"
```
