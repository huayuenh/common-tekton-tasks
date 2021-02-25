# git-clone v1.0.1  (DEPRECATED)

Clones a git repo to the workspace

**Note:** If running in a CI Pipeline you do not want to just clone the PR's repository.
You need to merge the content of the PR with the origin you are going to be merging into.
In tools like Jenkins and Travis CI this is handled for us. I have provided the option to
specify the origin which if set will preform the merge. You can get the origin value from
the Pull Request event with `$(events.pull_request.base.ref)` in your trigger binding.
For an example see the pipeline for [this repository](/.tekton)

When an error occurs during cloning the repository with the given branch or commit, the credentials are hidden in the error message.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

- **repository**: The git repository url we are cloning
- **branch**: (Default: `"master"`) The git branch or tag
- **origin**: (Default: `""`) The origin you wish to merge code with
- **revision**: (Default: `""`) The git revision/commit to clone empty to just use branch
- **directoryName**: (Default: `"."`) Name of the new directory to clone into on the workspace
- **git-user**: User to clone with. Leave blank to pickup the details from the workspace `/secrets/credentials/cred.json`
- **git-api-token-key**: (Default: `git-token`) The name of the secret that contains the git token for api authentication.
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit

- **GIT_TOKEN**: GitHub access token from `secrets` workspace

### Results:
- **git-url**: the git clone url
- **git-branch**: the git branch to be checked out
- **git-commit**: the latest commit of the cloned repo
- **directory-name**: the name of the folder where the repo was cloned

### Outputs
The repository should be cloned into the `artifacts` workspace

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks
 - **secrets**: The workspace where we store the secrets


### Usage
TaskRun pull master with GIT Credentials passed in
```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: git-clone-run
spec:
  taskRef:
    name: git-clone
  workspaces:
    - name: artifacts
      workspace: artifacts
    - name: secrets
      workspace: secrets
  params:
    - name: repository
      value: https://github.ibm.com/one-pipeline/common-tekton-tasks
```

Pipeline pull revision from branch with [git-get-credentials](#git-get-credentials)
```yaml
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
    - name: git-get-credentials
      taskRef:
        name: git-get-credentials
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: repository
          value: $(params.repository)

    - name: clone
      taskRef:
        name: git-clone
      runAfter:
        - git-get-credentials
      workspaces:
        - name: artifacts
          workspace: artifacts
        - name: secrets
          workspace: secrets
      params:
        - name: repository
          value: $(params.repository)
        - name: branch
          value: $(params.branch)
        - name: revision
          value: $(params.revision)
```
For a full example see the pipeline for [this repository](/.tekton)
