# compliance-detect-secrets v1.0.1 (DEPRECATED)

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

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
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
