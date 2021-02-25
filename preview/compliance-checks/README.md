# compliance-checks
Tasks for covering compliance controls

#### Tasks

- [compliance-check-github-statuses](#compliance-check-github-statuses)
- [compliance-collector](#compliance-collector)
- [compliance-detect-secrets](#compliance-detect-secrets)
- [compliance-doi-reporter](#compliance-doi-reporter)
- [compliance-unit-test](#compliance-unit-test)


## (DEPRECATED) compliance-check-github-statuses

Checks if the required github setting are set up, and required status checks have run and passed.

### Documentation

This task is using the [cocoa cli](https://github.ibm.com/cocoa/scripts)'s `check pull-request-status` command with the environment variables below. The command's documentation with an example `required-checks` can be found [here](https://github.ibm.com/cocoa/scripts#cocoa-check-pull-request-status).

### Report a Bug / Request a Feature

We track our issues in [this github repository](https://github.ibm.com/cocoa/board).
Please use the following issue templates to:
- [Report a Bug](https://github.ibm.com/cocoa/board/issues/new?template=bug.md)
- [Request a Feature](https://github.ibm.com/cocoa/board/issues/new?template=feature.md)

### Inputs

#### Parameters
 - **target-branch**: target branch where the required statuses and settings are checks
 - **required-checks**: array of required checks to verify in github
 - **gh-org**: The Github Organization/User (owner of the repository).
 - **repository**: The name of the repository to check.
 - **git-commit**: Hash of the given commit
 - **git-api-token-key**: (Default: `git-token`) The name of the secret that contains the git token for api authentication.
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
 - **retry-count**: (Default: `5`) retry count to check status-checks on a commit
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries

#### Implicit

The following inputs are coming from tekton annotation:

  - **PIPELINE_RUN_ID**: id of the current pipeline run
  - **PIPELINE_RUN_URL**: url of the current pipeline run

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

-**retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

 - **secrets**: The workspace where we store the secrets

### Usage

Example usage in a pipeline.

``` yaml
    - name: check-github-statuses
      taskRef:
        name: compliance-check-github-statuses
      workspaces:
        name: secrets
        workspace: secrets
      params:
        - name: target-branch
          value: $(params.branch)
        - name: required-checks
          value: |
          [{
            "type": "status",
            "name": "unit-test",
            "params": {
              "name": "tekton/ci-unit-tests"
            }
          }]
        - name: repository
          value: $(params.repository)
        - name: git-commit
          value: $(params.git-commit)
        - name: gh-org
          value: $(params.gh-org)
```

## (DEPRECATED) compliance-collector

Task to execute multiple jobs that are all related to compliance evidence collection form a pipeline run.
Because of the nature of the task, it is recommended to use this near the end of the pipeline.

Jobs executed in this task:

- create incident issues on task results if needed
- upload task artifacts
- fetch and upload pipeline logs (log including everything that precedes this task)
- create and upload compliance evidence

Previously these were separated tekton tasks, running after each test and check, but usage shown that these jobs are always executed together, so including all these jobs in a single task makes sense, and also shortens the pipeline.

### Inputs

#### ConfigMaps

- **compliance-helper-scripts**: from `./configmap-helper-scripts.yaml`
- **retry-command**: from `preview/util/configmap-retry.yaml`
- **cd-config-volume**: Provided by the pipeline, containing the `toolchain.json`

#### Parameters

- **data**: Task results from the pipeline in a JSON format, see the Usage section below
- **namespace**: pipeline namespace where the source of the evidence run ("ci or "cd")
- **incident-issue-repo**: The incident issue git repository
- **evidence-repo-url**: URL to the evidence git repo
- **commit-hash**: The commit hash on which the current build runs
- **toolchain-crn**: Cloud resource name of the toolchain the pipeline belongs to
- **cos-bucket-name**: (Default: `""`) Bucket name in your Cloud Object Storage instance, used as an Evidence Locker
- **cos-endpoint**: (Default: `""`) Endpoint of your Cloud Object Storage instance, used as an Evidence Locker
- **toolchain-apikey-secret-key**: (Default: `"ibmcloud-api-key"`) The IBM Cloud API key's secret name
- **continuous-delivery-context-secret**: (Default: `"secure-properties"`) Reference name for the secret resource
- **git-api-token-key**: (Default: `"git-token"`) The name of the secret that contains the git token for api authentication.
- **pipeline-debug**: (Default: `"0"`) pipeline debug switch to enable extensive debugging
- **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
- **retry-delay**: (Default: `"5"`) the amount of seconds between the retries
- **skip-pipeline-logs**: (Default: `"0"`) Skip pipeline data upload as artifact. Useful is this task is run more than once in a pipeline.

#### Secrets

- **secure-properties**: Secrets provided by the IBM Cloud pipeline, Secret resource name can be overwritten using the param `continuous-delivery-context-secret`

#### Implicit

 - **PIPELINE_ID**: unique id of the pipeline
 - **PIPELINE_RUN_ID**: unique id of the pipeline run
 - **PIPELINE_RUN_URL**: url to the given pipeline run

#### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks
- **secrets**: The workspace where we store runtime acquired secrets

### Usage

The `data` parameter is a JSON formatted array of the following objects:

```json
{
  "name": "", //task name that produced the result
  "step": "", // step name in the task named above
  "evidence_type": "com.ibm.test-or-task-type", // type of test or scan that will appear in compliance reports
  "evidence_type_version": "1.0.0", // version of evidence type
  "expected": "success", // expected result
  "actual": "", // output from the task that produced result
  "artifacts": [
    "", // paths of generated artifacts, scans test results...
  ]
},
```

Example usage in a pipeline:

```yaml

- name: build-compliance-collector
  taskRef:
    name: compliance-collector
  workspaces:
    - name: artifacts
      workspace: artifacts
    - name: secrets
      workspace: artifacts
  params:
    - name: namespace
      value: ci
    - name: incident-issue-repo
      value: $(tasks.code-extract-issues-repo-url.results.extracted-value)
    - name: evidence-repo-url
      value: $(tasks.code-extract-evidence-repo-url.results.extracted-value)
    - name: commit-hash
      value: $(tasks.code-fetch-code.results.git-commit)
    - name: toolchain-crn
      value: $(tasks.code-extract-toolchain-crn.results.extracted-value)
    - name: pipeline-debug
      value: $(params.pipeline-debug)
    - name: toolchain-apikey-secret-key
      value: "api-key"
    - name: data
      value: |
        [
          {
            "name": "code-detect-secrets",
            "step": "detect-secrets",
            "evidence_type": "com.ibm.detect_secrets",
            "evidence_type_version": "1.0.0",
            "expected": "success",
            "actual": "$(tasks.code-detect-secrets.results.status)",
            "artifacts": [
              "$(tasks.code-detect-secrets.results.artifact-path)"
            ]
          },
          {
            "name": "code-unit-tests",
            "step": "run-script",
            "evidence_type": "com.ibm.unit_test",
            "evidence_type_version": "1.0.0",
            "expected": "success",
            "actual": "$(tasks.code-unit-tests.results.status)",
            "artifacts": [
              "$(tasks.code-unit-tests.results.artifact-path)"
            ]
          }
        ]

```


## (DEPRECATED) compliance-detect-secrets

Task to run the [Detect Secrets Developer Tool](https://w3.ibm.com/w3publisher/detect-secrets/developer-tool) to check for secrets in the source code.
The task runs the `detect-secrets scan --update .secrets.baseline` command to check for secrets in the application repo. If the application repo already contains a `.secrets.baseline` file, it will use it as baseline, e.g not list secrets excluded in the baseline.
If the file is missing from the repo it will generate the baseline with every run, and list all secrets found.

The baseline file is a `json` file that contains information about excluded files, used plugins, secrets found and metadata.
False positives can be marked as such with the `detect-secrets audit .secrets.baseline` command and committing the updated baseline file into the application repo.

Example `.secrets.baseline`
```
{
  "exclude": {
    "files": "package-lock.json|^.secrets.baseline$",
    "lines": null
  },
  "generated_at": "2020-08-04T16:27:35Z",
  "plugins_used": [
    {
      "name": "AWSKeyDetector"
    },
    {
      "name": "ArtifactoryDetector"
    },
    {
      "base64_limit": 4.5,
      "name": "Base64HighEntropyString"
    },
    {
      "name": "BasicAuthDetector"
    },
    {
      "name": "BoxDetector"
    },
    {
      "name": "CloudantDetector"
    },
    {
      "name": "Db2Detector"
    },
    {
      "name": "GheDetector"
    },
    {
      "hex_limit": 3,
      "name": "HexHighEntropyString"
    },
    {
      "name": "IbmCloudIamDetector"
    },
    {
      "name": "IbmCosHmacDetector"
    },
    {
      "name": "JwtTokenDetector"
    },
    {
      "keyword_exclude": null,
      "name": "KeywordDetector"
    },
    {
      "name": "MailchimpDetector"
    },
    {
      "name": "PrivateKeyDetector"
    },
    {
      "name": "SlackDetector"
    },
    {
      "name": "SoftlayerDetector"
    },
    {
      "name": "StripeDetector"
    },
    {
      "name": "TwilioKeyDetector"
    }
  ],
  "results": {
    "pre-deploy-check.sh": [
      {
        "hashed_secret": "83c505306bc8a3aa4c15684f9109ac1b1b563afd",
        "is_secret": true,
        "is_verified": false,
        "line_number": 58,
        "type": "DB2 Credentials",
        "verified_result": null
      }
    ]
  },
  "version": "0.13.1+ibm.18.dss",
  "word_list": {
    "file": null,
    "hash": null
  }
}
```

### Inputs

#### Parameters

  - **app-directory**: (Default: `""`) path of the application

#### Workspaces

  - **artifacts**: The output volume to check out and store task scripts & data between tasks

### Outputs

#### Results

  - **exit-code**: The exit code of the `script`
  - **status**: Can be `success` or `failure` depending on the `exit-code`

### Usage

```
    - name: detect-secrets
      taskRef:
        name: compliance-detect-secrets
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: app-directory
          value: "path/to/your/app/repository"
```

## (DEPRECATED) compliance-doi-reporter

Task that accepts multiple results from preceding tasks, then converts and uploads them to Devops Insights as test results.

Using this task, you'll have a visual dashboard in DOI of your compliance results in your pipeline run.

### Inputs

#### ConfigMaps

- **compliance-helper-scripts**: from `./configmap-helper-scripts.yaml`
- **retry-command**: from `preview/util/configmap-retry.yaml`
- **cd-config-volume**: Provided by the pipeline, containing the `toolchain.json`

#### Parameters

- **data**: Task results from the pipeline in a JSON format, see the Usage section below
- **app-name**: Logical application name for DevOps Insights
- **environment**: (Default: `""`) The environment name to associate with the test results. This option is ignored for unit tests, code coverage tests, and static security scans.
- **build-number**: Devops Inisghts build number reference. Default to the CD Tekton Pipeline build number
- **toolchain-id**: Toolchain service instance id - Default to the toolchain containing the CD Tekton PipelineRun currently executed
- **ibmcloud-api-key-secret-key**: (Default: `"ibmcloud-api-key"`) The IBM Cloud API key's secret name
- **continuous-delivery-context-secret**: (Default: `"secure-properties"`) Reference name for the secret resource
- **ibmcloud-api**: (Default: `"https://cloud.ibm.com"`) the IBM Cloud API URL
- **pipeline-debug**: (Default: `"0"`) pipeline debug switch to enable extensive debugging
- **retry-count**: (Default: `"5"`) retry count to pull and push to the git evidence repo
- **retry-delay**: (Default: `"5"`) the amount of seconds between the retries

#### Implicit

 - **PIPELINE_ID**: unique id of the pipeline
 - **PIPELINE_RUN_ID**: unique id of the pipeline run
 - **PIPELINE_RUN_URL**: url to the given pipeline run
 - **DEFAULT_BUILD_NUMBER**: build number provided by the pipeline run

#### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks

## Usage

The `data` parameter is a JSON formatted array of the following objects:

```json
{
  "name": "", //task name that produced the result
  "step": "", // step name in the task named above
  "evidence_type": "com.ibm.test-or-task-type", // type of test or scan
  "expected": "success", // expected result
  "actual": "", // output from the task that produced result
},
```

Example usage in a pipeline:

```yaml
- name: build-compliance-doi-reporter
  taskRef:
    name: compliance-doi-reporter
  workspaces:
    - name: artifacts
      workspace: artifacts
  params:
    - name: app-name
      value: "$(params.app-name)"
    - name: pipeline-debug
      value: $(params.pipeline-debug)
    - name: ibmcloud-api-key-secret-key
      value: "api-key"
    - name: data
      value: |
        [
          {
            "name": "code-detect-secrets",
            "step": "detect-secrets",
            "evidence_type": "com.ibm.detect_secrets",
            "expected": "success",
            "actual": "$(tasks.code-detect-secrets.results.status)"
          },
          {
            "name": "code-unit-tests",
            "step": "run-script",
            "evidence_type": "com.ibm.unit_test",
            "expected": "success",
            "actual": "$(tasks.code-unit-tests.results.status)"
          },
        ]
```


## (DEPRECATED) compliance-unit-test
Task to run unit tests, using `npm run test`

### Inputs

#### Parameters

  - **context**: the context of the unit tests
  - **repository**: (Default: `""`) name of the git repository
  - **git-commit**: (Default: `""`) the commit id
  - **app-directory**: (Default: `""`) path of the application

#### Implicit

- **GH_ORG**: Name of the GH organization from `/cd-config/toolchain.json`
- **TOOLCHAIN_ID**: Unique ID of the toolchain from `/cd-config/toolchain.json`
- **TOOLCHAIN_REGION**: Region of the toolchain from `/cd-config/toolchain.json`
- **REPO**: DEPRECATED - Name of the GHE repository of the application from `/artifacts/build.properties`
- **APP_DIRECTORY**: DEPRECATED - Name of the repository of the application from `/artifacts/build.properties`
- **GIT_COMMIT**: DEPRECATED - Hash of the given commit from `/artifacts/build.properties`

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks

### Usage

Example usage in a pipeline.

``` yaml
    - name: unit-tests
      workspaces:
        - name: artifacts
          workspace: artifacts
      taskRef:
        name: compliance-unit-test
      params:
        - name: context
          value: tekton/ci-unit-tests
        - name: pipeline-debug
          value: $(params.pipeline-debug)
```
