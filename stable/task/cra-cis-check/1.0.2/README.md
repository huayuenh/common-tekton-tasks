# cra-cis-check v1.0.2
Runs configuration checks on kubernetes deployment manifests.

Docker CIS provides prescriptive guidance for establishing a secure configuration posture for Docker container.
Code Risk Analyzer takes these security configurations as point of reference and identifies security controls that can be
checked in the deployment artifacts (*.yaml) for kubernetes applications.
In addition, this task also provided security `risk` for every control failure.

We identified following controls from CIS Docker 1.13.0 that we can implement in DevSecOps. Some additional controls are added based on open source references of [KCCSS](https://github.com/octarinesec/kccss)



|ID | Rule | Risk |
|---------|---------|:----------:|
|5.3|Ensure containers do not have CAP_SYS_ADMIN capability|High|
|5.3|Ensure containers do not have CAP_NET_RAW capability|High|
|5.4|Ensure privileged containers are not used|High|
|5.5|Ensure sensitive host system directories are not mounted on containers|Medium|
|5.7|Ensure privileged ports are not mapped within containers|Low|
|5.9|Ensure the host's network namespace is not shared|Medium|
|5.10|Ensure memory usage for container is limited|Medium|
|5.11|Ensure CPU priority is set appropriately on the container|Medium|
|5.12|Ensure the container's root filesystem is mounted as read only|Medium|
|5.15|Ensure the host's process namespace is not shared|Medium|
|5.16|Ensure the host's IPC namespace is not shared|Medium|
|5.31|Ensure the Docker socket is not mounted inside any containers|High|
|-|Ensure containers do not allow unsafe allocation of CPU resources|Medium|
|-|Ensure containers do not allow privilege escalation|Medium|
|-|Ensure containers do not expose unsafe parts of /proc|Medium|
|-|Ensure containers are not exposed through a shared host port|Medium|



### Inputs

#### Parameters

  - **ibmcloud-api**: (Default: `https://cloud.ibm.com`) The ibmcloud api url
  - **repository**: The full URL path to the repo with the deployment files to be scanned
  - **revision**: (Default: `master`) The branch to scan
  - **commit-id**: The commit id of change
  - **pr-url**: The pull request url
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **git-api-token-key**: (Default: `git-token`) Name of the secret that contains the git api token
  - **ibmcloud-api-key-secret-key**: (Default: `api-key`) field in the secret that contains the api key used to login to ibmcloud
  - **resource-group**: (Default: `""`) target resource group (name or id) for the ibmcloud login operation
  - **project-id**: (Default: `""`) Required id for GitLab repositories
  - **directory-name**: The directory name where the repository is cloned
  - **scm-type**: (Default: `github-ent`) Source code type used (github, github-ent, gitlab)
  - **pipeline-debug**: (Default: `0`) 1 = enable debug, 0 no debug


#### Implicit
The following inputs are coming from tekton annotation:
 - **PIPELINE_RUN_ID**: ID of the current pipeline run

### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks
- **secrets**: The workspace where we store the secrets

### Results

- **status**: status of cra cis check task, possible value are-success|failure
- **evidence-store**: filepath to store cis check task evidence

### Usage

Example usage in a pipeline.
``` yaml
    - name: cra-cis-check
      taskRef:
        name: cra-cis-check
      runAfter:
        - cra-discovery-scan
      workspaces:
        - name: secrets
          workspace: artifacts
        - name: artifacts
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
        - name: directory-name
          value: $(params.directory-name)
        - name: scm-type
          value: $(params.scm-type)
        - name: project-id
          value: $(params.project-id)
        - name: pipeline-debug
          value: $(params.pipeline-debug)
```
