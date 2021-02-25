# cra-discovery v1.0.0

This task accesses various source artifacts from the repository and performs deep discovery
to identify all dependencies (including transitive dependencies). Specifically, it parses the following assets:

1. Dockerfile: All Build stages, Base Images in every stage, list of packages from base images,
any add-on packages installed on top of base image(s).

2. Package Manifests: requirements.txt (python), package-lock.json (Node.js), pom.xml (java)


### Inputs

#### Parameters

  - **repository**: The full URL path to the repo with the deployment files to be scanned
  - **revision**: (Default: `master`) The branch to scan
  - **commit-id**: The commit id of the change
  - **commit-timestamp**: the timestamp of when the commit pushed
  - **directory-name**:  The directory name where the repository is cloned
  - **pipeline-debug**: (Default: `0`) 1 = enable debug, 0 no debug
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **ibmcloud-api-key-secret-key**: (Default: `api-key`) field in the secret that contains the api key used to login to ibmcloud

### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks

#### Implicit / data from the pipeline

**Base image pulls secrets (optional)**

To provide pull credentials for the base image you use in your Dockerfile, for example for a UBI image from Red Hat registry, add these variables to your pipeline on he pipeline UI. The Task will look for them and if they are present, it will add an entry to the proper `config.json` for docker.

- **baseimage-auth-user** The username to the registry (Type: `text`)
- **baseimage-auth-password** The password to the registry (Type: `SECRET`)
- **baseimage-auth-host** The registry host name (Type: `text`)
- **baseimage-auth-email** An email address to the registry account (Type: `text`)

### Results

- **status**: Status of cra discovery task, possible value are - success|failure

### Usage

Example usage in a pipeline.
``` yaml
    - name: cra-discovery-scan
      runAfter:
        - cra-fetch-repo
      taskRef:
        name: cra-discovery
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
        - name: pipeline-debug
          value: $(params.pipeline-debug)
        - name: directory-name
          value: $(params.directory-name)
        - name: commit-timestamp
          value: $(params.commit-timestamp)
        - name: continuous-delivery-context-secret
          value: "secure-properties"
        - name: ibmcloud-api-key-secret-key
          value: "api-key"
```
