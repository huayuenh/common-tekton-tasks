# terraform
Tasks for covering compliance controls of terraform

#### Tasks

- [terraform-lint](#terraform-lint)
- [terraform-config-advisor](#terraform-config-advisor)

## terraform-lint
Runs terraform validatation to insure syntax is correct.

### Inputs

#### Parameters
  - **repository**: The full URL path to the repository with the terraform files to be scanned
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **git-api-token-key**: (Default: `git-token`) The git token's secret name
  - **pipeline-debug**: (Default: `"0"`) set environment variable PIPELINE_DEBUG to enable pipeline debug mode
  - **tf-dir**: (Default: `"."`) set the terraform directory within the repo to check

#### Implicit

  - **git-api-token-key**: git token from the `/secrets` volume

## Usage

Example usage in a pipeline.
``` yaml
    - name: code-terraform-lint
      runAfter:
        - code-fetch-code
      taskRef:
        name: terraform-lint
      workspaces:
        - name: artifacts
          workspace: artifacts
        - name: secrets
          workspace: artifacts
      params:
        - name: repository
          value: $(tasks.code-extract-repository-url.results.extracted-value)
        - name: git-api-token-key
          value: git-token
        - name: pipeline-debug
          value: $(params.pipeline-debug)
        - name: tf-dir
          value: $(params.tf-dir)
```

## terraform-config-advisor
Runs terraform configuration assessment for compliance with regulations.

### Inputs

#### Parameters
  - **repository**: The full URL path to the repository with the terraform files to be scanned
  - **revision**: The branch to scan
  - **pr-number**: The number of the PR that triggered the pipeline run
  - **commit-id**: The commit id of change
  - **silent**: Trigger silent mode
  - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
  - **git-api-token-key**: (Default: `git-token`) The git token's secret name
  - **pipeline-debug**: (Default: `"0"`) set environment variable PIPELINE_DEBUG to enable pipeline debug mode
  - **tf-dir: (Default: ".") set the terraform directory within the repo to check
  - **policy-threshold: (Default: "2") set the threshold used for all aggregation policies

#### Implicit

  - **git-api-token-key**: git token from the `/secrets` volume

## Usage

Example usage in a pipeline.
``` yaml
    - name: terraform-compliance-check
      runAfter:
        - code-vulnerability-scan-status-pending
      taskRef:
        name: terraform-config-advisor
      workspaces:
        - name: artifacts
          workspace: artifacts
        - name: secrets
          workspace: artifacts
      params:
        - name: repository
          value: $(params.repository)
        - name: revision
          value: $(params.branch)
        - name: commit-id
          value: $(params.commit-id)
        - name: pr-number
          value: $(params.pr-url)
        - name: git-api-token-key
          value: git-token
        - name: silent
          value: "1"
        - name: policy-threshold
          value: $(params.policy-threshold)
```
