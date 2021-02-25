# devops-insights
IBM Cloud Devops Insights related tasks

The `sample` sub-directory contains an EventListener and Pipeline definition that you can include in your Tekton pipeline configuration to run an example of the differents DOI related tasks.

#### Tasks
- [doi-publish-buildrecord](#doi-publish-buildrecord)
- [doi-publish-testrecord](#doi-publish-testrecord)
- [doi-publish-deployrecord](#doi-publish-deployrecord)
- [doi-evaluate-gate](#doi-evaluate-gate)

## doi-publish-buildrecord (_deprecated_)
This task publishes build record to DevOps Insights

This task is deprecated, use [`devops-insights-publish-build`](../../stable/task/devops-insights-publish-build) instead.

### Inputs

#### Parameters

- **app-name**: application name for devops insights
- **toolchain-id**: (Default: `""`) toolchain service instance id
- **build-number**: (Default: `""`) devops insights build number reference
- **build-status**: (Default: `pass`) the build status (can be either `pass` | `fail`)
- **git-repository**: the url of the git repository
- **git-branch**: the repository branch on which the build has been performed
- **git-commit**: the git commid id
- **job-url**: (Default: `""`) the url to the job's build logs
- **ibmcloud-api**: (Default: `https://cloud.ibm.com`) the ibmcloud api url
- **continuous-delivery-context-secret**: (Default: `secure-properties`) name of the configmap containing the continuous delivery pipeline context secrets
- **toolchain-apikey-secret-key**: (Default: `toolchain-apikey`) field in the secret that contains the api key used to access toolchain and DOI instance
- **pipeline-debug**: (Default: `0`) pipeline debug mode

#### Implicit

The following params comes from tekton annotations:

- **PIPELINE_RUN_URL**: url to the given pipeline run
- **DEFAULT_BUILD_NUMBER**: build number of the pipeline

The following params comes from `cd-config/toolchain.json`:

- **CURRENT_TOOLCHAIN_ID**: id of the current toolchain
- **DOI_IN_TOOLCHAIN**: positive number if the toolchain contains devops insights integration

### Usage

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  params:
    - name: app-name
    - name: branch
    - name: repository
    - name: commit
    - name: pipeline-debug
  tasks:
    - name: doi-publish-buildrecord
      taskRef:
        name: doi-publish-buildrecord
      params:
        - name: app-name
          value: "$(params.app-name)"
        - name: toolchain-apikey-secret-key
          value: "api-key"
        - name: git-repository
          value: $(params.repositorty)
        - name: git-branch
          value: $(params.branch)
        - name: git-commit
          value: $(params.commit)
        - name: pipeline-debug
          value: $(params.pipeline-debug)
```

## (DEPRECATED) doi-publish-testrecord
This task publishes test record to DevOps Insights

### Inputs

#### Parameters

- **app-name**: application name for devops insights
- **toolchain-id**: (Default: `""`) toolchain service instance id
- **build-number**: (Default: `""`) devops insights build number reference
- **file-locations**: semi-colon separated list of test result file locations
- **test-types**: semi-colon separated list of test result types
- **environment**: (Default: `""`) environment name to associate with the test results. This option is ignored for unit tests, code coverage tests, and static security scans
- **ibmcloud-api**: (Default: `https://cloud.ibm.com`) the ibmcloud api url
- **continuous-delivery-context-secret**: (Default: `secure-properties`) name of the configmap containing the continuous delivery pipeline context secrets
- **toolchain-apikey-secret-key**: (Default: `toolchain-apikey`) field in the secret that contains the api key used to access toolchain and DOI instance
- **retry-count**: (Default: `5`) retry count to pull and push git evidence repo
- **retry-delay**: (Default: `10`) the amount of seconds between the retries
- **pipeline-debug**: (Default: `0`) pipeline debug mode

#### Implicit

The following params comes from tekton annotations:

- **DEFAULT_BUILD_NUMBER**: build number of the pipeline

The following params comes from `cd-config/toolchain.json`:

- **CURRENT_TOOLCHAIN_ID**: id of the current toolchain
- **DOI_IN_TOOLCHAIN**: positive number if the toolchain contains devops insights integration

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

- **artifacts**: workspace containing the test results file to pubslih to DOI

### Usage

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  params:
    - name: app-name
    - name: file-locations
    - name: test-types
    - name: pipeline-debug
  tasks:
    - name: doi-publish-testrecord
      taskRef:
        name: doi-publish-testrecord
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: app-name
          value: "$(params.app-name)"
        - name: file-locations
          value: $(params.file-locations)
        - name: test-types
          value: $(params.test-types)
        - name: toolchain-apikey-secret-key
          value: "api-key"
        - name: pipeline-debug
          value: $(params.pipeline-debug)
```

## (DEPRECATED) doi-publish-deployrecord
This task publishes deploy record to DevOps Insights

### Inputs

#### Parameters

- **app-name**: application name for devops insights
- **toolchain-id**: (Default: `""`) toolchain service instance id
- **build-number**: (Default: `""`) devops insights build number reference
- **environment**: environment where the pipeline job deployed the app
- **job-url**: (Default: `""`) url to the job's deployment logs
- **app-url**: (Default: `""`) url where the deployed app is running
- **ibmcloud-api**: (Default: `https://cloud.ibm.com`) the ibmcloud api url
- **continuous-delivery-context-secret**: (Default: `secure-properties`) name of the configmap containing the continuous delivery pipeline context secrets
- **toolchain-apikey-secret-key**: (Default: `toolchain-apikey`) field in the secret that contains the api key used to access toolchain and DOI instance
- **pipeline-debug**: (Default: `0`) pipeline debug mode

#### Implicit

The following params comes from tekton annotations:

- **PIPELINE_RUN_URL**: url to the given pipeline run
- **DEFAULT_BUILD_NUMBER**: build number of the pipeline

The following params comes from `cd-config/toolchain.json`:

- **CURRENT_TOOLCHAIN_ID**: id of the current toolchain
- **DOI_IN_TOOLCHAIN**: positive number if the toolchain contains devops insights integration

### Usage

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  params:
    - name: application
    - name: doi-toolchain-id
    - name: build-number
    - name: pipeline-debug
  tasks:
    - name: doi-publish-deployrecord
      taskRef:
        name: doi-publish-deployrecord
      params:
        - name: app-name
          value: "$(params.application)"
        - name: toolchain-id
          value: "$(params.doi-toolchain-id)"
        - name: build-number
          value: "$(params.build-number)"
        - name: environment
          value: "prod"
        - name: app-url
          value: "http://example.com"
        - name: toolchain-apikey-secret-key
          value: "ibmcloud-api-key"
        - name: pipeline-debug
          value: "$(params.pipeline-debug)"
```

## doi-evaluate-gate
This task evaluates DevOps Insights gate policy

### Inputs

#### Parameters

- **app-name**: application name for devops insights
- **toolchain-id**: (Default: `""`) toolchain service instance id
- **build-number**: (Default: `""`) devops insights build number reference
- **policy**: name of the policy that the gate uses to make its decision
- **force**: (Default: `true`) indicate if the evaluation gate should be forced or not (`true` | `false`)
- **ibmcloud-api**: (Default: `https://cloud.ibm.com`) the ibmcloud api url
- **continuous-delivery-context-secret**: (Default: `secure-properties`) name of the configmap containing the continuous delivery pipeline context secrets
- **toolchain-apikey-secret-key**: (Default: `toolchain-apikey`) field in the secret that contains the api key used to access toolchain and DOI instance
- **pipeline-debug**: (Default: `0`) pipeline debug mode

#### Implicit

The following params comes from tekton annotations:

- **DEFAULT_BUILD_NUMBER**: build number of the pipeline

The following params comes from `cd-config/toolchain.json`:

- **CURRENT_TOOLCHAIN_ID**: id of the current toolchain
- **DOI_IN_TOOLCHAIN**: positive number if the toolchain contains devops insights integration

### Usage

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  params:
    - name: app-name
    - name: pipeline-debug
  tasks:
    - name: doi-evaluate-gate
      taskRef:
        name: doi-evaluate-gate
      params:
        - name: app-name
          value: $(params.app-name)
        - name: policy
          value: "my-policy"
        - name: pipeline-debug
          value: $(params.pipeline-devug)
```
