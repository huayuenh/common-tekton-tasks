## ciso-image-sign@v3.0.0
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
- **taas-artifactory-user**: (Default: `""`) The TaaS Artifactory user
- **taas-artifactory-api-token-secret-key**: (Default: `taas-artifactory-token`) The Taas Artifactory API key's secret name
- **artifactory-primary-service**: (Default: `eu`) Your team's primary Artifactory service where your team has write access (Will be either 'na' or 'eu'.)
- **artifactory-docker-repo-name**: (Default: `""`) The TaaS Artifactory Docker repository where you will publish your image
- **artifactory-sigstore-repo-name**: (Default: `""`) The TaaS Artifactory Generic repository where you will store your signatures
- **artifactory-signing**: (Default: `0`) Flag.  If your image is stored in Artifactory, you have to give non zero value
#### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks

### Outputs
Adds a signature file for the image in the IBM Container Registry or in your TaaS Artifactory Generic repository.

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
        name: ciso-image-sign
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

```yaml
- name: signing
      runAfter:
        - some-task
      taskRef:
        name: ciso-image-sign
      params:
        - name: image
          value: "my-image"
        - name: image-digest
          value: "the expected image digest"
        - name: taas-artifactory-user
          value: "a@b.com"
        - name: artifactory-docker-repo-name
          value: "your-artifactory-docker-repo-name"
        - name: artifactory-sigstore-repo-name
          value: "your-artifactory-generic-local-repo-name"
        - name: artifactory-signing
          value: "1"
      workspaces:
        - name: artifacts
          workspace: artifacts
```