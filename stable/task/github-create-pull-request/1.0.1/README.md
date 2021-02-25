# (DEPRECATED) github-create-pull-request v1.0.1

This task creates a pull request in a given repository on GitHub Enterprise. To use this `Task`, add a `Workspace` to the `Task` in your `Pipeline` which contains a Github API Token as a secret.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters
 - **owner**: Required. The owner of the repository. (string)
 - **repository**: Required. The name of the repository. (string)
 - **head**: Required. The name of the branch where your changes are implemented. For cross-repository pull requests in the same network, namespace head with a user like this: username:branch. (string)
 - **base**: Required. The name of the branch you want the changes pulled into. This should be an existing branch on the current repository. You cannot submit a pull request to one repository that requests a merge to a base of another repository. (string)
 - **title**: Required. The title of the new pull request. (string)
 - **body**: The contents of the pull request. (string)
 - **draft**: Indicates whether the pull request is a draft. (boolean, possible values: 0 - default / 1)
 - **maintainer-can-modify**: Indicates whether maintainers can modify the pull request. (boolean, possible values: 0 / 1 - default)
 - **git-api-token-key**: github enterprise api token secret name (Default: `git-token`)

### Usage
Pipeline with a workspace which has a secret `git-token` in it.

This `Task` will open a pull request to `master` branch from `feat/example-branch`.

```yaml
- name: create-pull-request
  taskRef:
    name: github-create-pull-request
  workspaces:
    - name: secrets
      workspace: artifacts
  params:
    - name: owner
      value: "your-username"
    - name: repository
      value: "your-repo-name"
    - name: head
      value: "feat/example-branch"
    - name: base
      value: "master"
    - name: title
      value: "Automated Build Promotion"
    - name: body
      value: "This Pull Request was created by a Tekton Task!"
```
