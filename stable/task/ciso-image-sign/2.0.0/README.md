## ciso-image-sign@v2.0.0 (DEPRECATED)
Signs the image

### Inputs

#### Parameters

- **registry-region**: the image registry region
- **image**: the image url
- **image-digest**: the specific image digest
- **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
- **toolchain-apikey-secret-key**: (Default: `api-key`) The IBM Cloud API key's secret name
- **vault-secret**: (Default: `vault-secret`) base64 encoded CISO pfx file data
- **ibmcloud-api**: (Default: `https://cloud.ibm.com`) the ibmcloud api endpoint
- **evidence**: (Default: `signature-evidence.json`) evidence file name
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
- **break-glass-key**: (Default: `'break_glass'`) Key in the `break-glass-name` `ConfigMap` that holds the Break-Glass mode settings
- **break-glass-name**: (Default: `'environment-properties'`) Name of the `ConfigMap` that holds Break-Glass mode settings

#### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks

### Outputs
Adds a signature file for the image in the IBM Container Registry

#### Results
- **exit-code**: stores the exit code of the task run
- **status**: stores success or failure or skipped (in Break-Glass mode) status of the task run
- **signature**: stores the signature data file name
- **signature-content**: the signature data

### Usage

```yaml
- name: signing
      runAfter:
        - some-task
      taskRef:
        name: ciso-sign
      params:
        - name: registry-region
          value: "us-south"
        - name: image
          value: "my-image"
        - name: image-digest
          value: "the expected image digest"
      workspaces:
        - name: artifacts
          workspace: artifacts
```
