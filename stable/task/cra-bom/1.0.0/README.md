# (DEPRECATED) cra-bom v1.0.0
Bill-of-Material (BoM) for a given repository captures pedigree of all the dependencies and it is collected at different granularities. For instance, it captures list of base images used in the build, list of packages from the base images, list of application packages installed over base image. The BoM essentially acts as a ground truth for our analytic results and can potentially be used to enforce policy gates.

### Inputs

#### Parameters

  - **ibmcloud-api**: (Default: `https://cloud.ibm.com`) The ibmcloud api url
  - **repository**: The full URL path to the repo with the deployment files to be scanned
  - **revision**: (Default: `master`) The branch to scan
  - **commit-id**: The commit id of change
  - **pr-url**: (Default: "") The pull request html url
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **ibmcloud-api-key-secret-key**: (Default: `api-key`) field in the secret that contains the api key used to login to ibmcloud
  - **resource-group**: (Default: `""`) target resource group (name or id) for the ibmcloud login operation
  - **git-access-token**: (Default: `""`) (optional) token to access the git repository. If this token is provided, there will not be an attempt to use the git token obtained from the authorization flow when adding the git integration in the toolchain
  - **target-branch**: (Default: `""`) The target branch for comparison
  - **target-commit-id**: (Default: `""`) The target commit id for comparison
  - **project-id**: (Default: `""`) Required id for GitLab repositories
  - **scm-type**: (Default: `github-ent`) Source code type used (github, github-ent, gitlab)
  - **pipeline-debug**: (Default: `0`) 1 = enable debug, 0 no debug

#### Implicit
The following inputs are coming from tekton annotation:
 - **PIPELINE_RUN_ID**: ID of the current pipeline run

### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks
- **secrets**: The workspace where we store the secrets

### Results

- **status**: status of cra bom task, possible value are-success|failure
- **evidence-store**: filepath to store bom task evidence

### Usage

```yaml
    - name: cra-bom
      taskRef:
        name: cra-bom
      runAfter:
        - cra-discovery-scan
      workspaces:
        - name: artifacts
          workspace: artifacts
        - name: secrets
          workspace: artifacts
      params:
        - name: ibmcloud-api
          value: $(params.ibmcloud-api)
        - name: repository
          value: $(params.repository)
        - name: revision
          value: $(params.branch)
        - name: pr-url
          value: $(params.pr-url)
        - name: commit-id
          value: $(params.commit-id)
        - name: continuous-delivery-context-secret
          value: "secure-properties"
        - name: ibmcloud-api-key-secret-key
          value: "api-key"
        - name: resource-group
          value: $(params.resource-group)
        - name: git-access-token
          value: ""
        - name: target-branch
          value: $(params.target-branch)
        - name: target-commit-id
          value: $(params.target-commit-id)
        - name: scm-type
          value: $(params.scm-type)
        - name: project-id
          value: $(params.project-id)
        - name: pipeline-debug
          value: $(params.pipeline-debug)
```
