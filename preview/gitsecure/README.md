# gitsecure checks

Tasks to scan your codebase using the GitSecure team scanners

#### Tasks

- [gitsecure-bom-check](#gitsecure-bom-check)
- [gitsecure-discovery](#gitsecure-discovery)
- [gitsecure-cis-check](#gitsecure-cis-check)
- [gitsecure-evidence-emitter](#gitsecure-evidence-emitter)
- [gitsecure-ossc-check](#gitsecure-ossc-check)
- [gitsecure-vulnerability-remediation](#gitsecure-vulnerability-remediation)


## gitsecure-bom-check

### Inputs

#### Parameters

  - **repository**: The full URL path to the repo with the deployment files to be scanned
  - **revision**: The branch to scan
  - **commit-id**: The commit id of change
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name

#### Implicit

 - **IBM_CLOUD_API_KEY**: The IBM Cloud API key from `/secrets` volume

The following inputs are coming from tekton annotation:

 - **PIPELINE_RUN_ID**: ID of the current pipeline run

### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks

### Results

- **status**: status of gitsecure bom task, possible value are-success|failure
- **evidence-store**: filepath to store bom task evidence

### Usage

```yaml
    - name: code-bom-check
      taskRef:
        name: gitsecure-bom-check
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: repository
          value: $(params.repository)
        - name: revision
          value: $(params.branch)
        - name: ibmcloud-api-key-secret-key
          value: api-key
        - name: commit-id
          value: $(tasks.code-fetch-code.results.git-commit)
```

## gitsecure-discovery

This task accesses various source artifacts from the repository and performs deep discovery
to identify all dependencies (including transitive dependencies). Specifically, it parses the following assets:

1. Dockerfile: All Build stages, Base Images in every stage, list of packages from base images,
any add-on packages installed on top of base image(s).

2. Package Manifests: requirements.txt (python), package-lock.json(js), pom.xml (java)


### Inputs
  - **revision**: The branch to scan
  - **repository**: The full URL path to the repo with the deployment files to be scanned
  - **commit-id**: The commit id of change

#### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks

#### Parameters
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

### Results

- **status**: Status of gitsecure discovery task, possible value are - success|failure


### Usage

Example usage in a pipeline.
``` yaml
    - name: gitsecure-vulnerability-scan
      runAfter:
        - gitsecure-vulnerability-scan-status-pending
      taskRef:
        name: gitsecure-discovery
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: repository
          value: $(params.repository)
        - name: revision
          value: $(params.branch)
        - name: commit-id
          value: $(params.commit-id)
```

## gitsecure-cis-check
Runs configuration checks on kubernetes deployment manifests.

Docker CIS provides prescriptive guidance for establishing a secure configuration posture for Docker container.
GitSecure takes these security configurations as point of reference and identifies security controls that can be
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
  - **revision**: The branch to scan
  - **repository**: The full URL path to the repo with the deployment files to be scanned
  - **commit-id**: The commit id of change
  - **pr-url**: The URL to the related PR
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name

#### Implicit

 - **IBM_CLOUD_API_KEY**: The IBM Cloud API key from `/secrets` volume

The following inputs are coming from tekton annotation:

 - **PIPELINE_RUN_ID**: ID of the current pipeline run

### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks

### Usage

Example usage in a pipeline.
``` yaml
    - name: gitsecure-cis
      taskRef:
        name: gitsecure-cis-task
      runAfter: [gitsecure-vuln]
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: repository
          value: $(params.repository)
        - name: revision
          value: $(params.branch)
        - name: pr-url
          value: $(params.pr-url)
        - name: commit-id
          value: $(params.commit-id)
```


## gitsecure-ossc-check
Runs Open Source licence checks.

### Inputs
  - **repository**: The full URL path to the repo with the deployment files to be scanned
  - **revision**: The branch to scan
  - **commit-id**: The commit id of change
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name

#### Implicit

 - **IBM_CLOUD_API_KEY**: The IBM Cloud API key from `/secrets` volume

### Usage

Example usage in a pipeline.
``` yaml
    - name: gitsecure-ossc-check
      taskRef:
        name: gitsecure-ossc-check
      params:
        - name: revision
          value: $(params.branch)
        - name: repository
          value: $(params.repository)
        - name: commit-id
          value: $(params.commit-id)
```

## gitsecure-vulnerability-remediation
Runs gitsecure/rig-recommend

### Inputs
  - **repository**: The full URL path to the repo with the deployment files to be scanned
  - **revision**: The branch to scan
  - **pr-url**: Pull request url
  - **commit-id**: The commit id of change
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name

#### Implicit

 - **IBM_CLOUD_API_KEY**: The IBM Cloud API key from `/secrets` volume

The following inputs are coming from tekton annotation:

 - **PIPELINE_RUN_ID**: ID of the current pipeline run


### Workspaces

  - **artifacts**: The output volume to check out and store task scripts & data between tasks

### Usage

Example usage in a pipeline.
``` yaml
    - name: gitsecure-vulnerability-remediation
      taskRef:
        name: gitsecure-vulnerability-remediation
      params:
        - name: revision
          value: $(params.branch)
        - name: repository
          value: $(params.repository)
        - name: pr-url
          value: $(params.pr-url)
        - name: commit-id
          value: $(params.commit-id)
```
