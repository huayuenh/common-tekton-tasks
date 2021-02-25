## (DEPRECATED) ciso-image-sign@v1.0.1
Signs the image

### Inputs

#### Parameters

- **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
- **toolchain-apikey-secret-key**: (Default: `api-key`) The IBM Cloud API key's secret name
- **vault-secret**: base64 encoded CISO pfx file data
- **region**: the target region
- **resource-group**: the resource group
- **registry-region**: the image registry region
- **registry-namespace**: the namespace in the registry
- **image-name**: the targeted image name
- **image-tag**: the specific image tag
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
- **ibmcloud-api**: (Default: `https://cloud.ibm.com`) the ibmcloud api endpoint
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
### Usage

```yaml
- name: signing
      runAfter:
        - some-task
      taskRef:
        name: ciso-sign
      params:
        - name: vault-secret
          value: "vault-integration-containing-ciso-pfx-file"
        - name: region
          value: "us-south"
        - name: resource-group
          value: "Default"
        - name: registry-region
          value: "us-south"
        - name: registry-namespace
          value: "my-registry-namespace"
        - name: image-name
          value: "my-image-name"
        - name: image-tag
          value: "the expected tag"
      workspaces:
        - name: artifacts
          workspace: artifacts
```
