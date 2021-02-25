## skopeo-copy-image@v1.0.1

The task to copy image from source container registry to target container registry.

### Context - ConfigMap/Secret

  The task expects the following kubernetes resources to be defined:

* **Secret cd-secret**

  Secret containing:
  * **SOURCE_PASSWORD**: An api key used to access to the source container registry service.
  * **TARGET_PASSWORD**: An api key used to access to the target container registry service.

### Parameters

* **source-image-name**: (Optional) Source image name. - Required if no `source-image-repository` value provided.
* **source-image-repository**: (Optional) URL of the source image.
* **source-image-digest**: SHA id of the source image.
* **target-image-name**: (Optional) Target image name. (If no provided, the target image name is same as source image name.)
* **target-image-repository**: (Optional) URL of the target image.
* **image-tags**: (Default: `latest`) The source image's tags.
* **source-registry-url**: (Optional) The source image registry url. - Required if no `source-image-repository` value provided.
* **target-registry-url**: (Optional) The target image registry url. - Required if no `target-image-repository` value provided.
* **source-registry-namespace**: (Optional) The source image registry namespace. - Required if image url contains registry namespace, but no `source-image-repository` value provided.
* **target-registry-namespace**: (Optional) The source image registry namespace. - Required if image url contains registry namespace, but no `target-image-repository` value provided.
* **source-username**: Source container registry service authentication email or username.
* **target-username**: Target container registry service authentication email or username.
* **source-email**: Source container registry service authentication email.
* **target-email**: Target container registry service authentication email.
* **source-password-secret-key**: (Default: `source-password-secret-key`) The source registry service API key's secret name.
* **destination-password-secret-key**: (Default: `destination-password-secret-key`) The destination registry service API key's secret name.
* **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource.
* **continuous-delivery-context-environment**: (Default: `environment-properties`) Name of the ConfigMap containing the continuous delivery pipeline context environment properties.
* **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode.

### Workspaces

* **source**: A workspace containing the source (Dockerfile, Docker context) to create the image

### Usages

```yaml
    name: build-skopeo-copy-image
      taskRef:
        name: skopeo-copy-image
      workspaces:
        - name: source
          workspace: artifacts
      params:
        - name: source-registry-namespace
          value: "example-namespace"
        - name: source-image-name
          value: "example-image-name"
        - name: image-tags
          value: "1.0.0, 1, 1.0"
        - name: source-image-digest
          value: "sha256:11111111111111111111111111"
        - name: source-registry-url
          value: "us.icr.io"
        - name: target-registry-url
          value: "wcp-compliance-automation-team-docker-local.artifactory.swg-devops.com"
        - name: source-email
          value: "a@b.com"
        - name: target-email
          value: "a@b.com"
        - name: source-username
          value: "your-username"
        - name: target-username
          value: "your-username"
        - name: pipeline-debug
          value: "1"
```

```yaml
    name: build-skopeo-copy-image
      taskRef:
        name: skopeo-copy-image
      workspaces:
        - name: source
          workspace: artifacts
      params:
        - name: source-image-repository
          value: "us.icr.io/example/app"
        - name: image-tags
          value: "1.0.0, 1, 1.0"
        - name: source-image-digest
          value: "sha256:11111111111111111111111111"
        - name: target-image-repository
          value: "wcp-compliance-automation-team-docker-local.artifactory.swg-devops.com/app-image"
        - name: source-email
          value: "a@b.com"
        - name: target-email
          value: "a@b.com"
        - name: source-username
          value: "your-username"
        - name: target-username
          value: "your-username"
        - name: pipeline-debug
          value: "1"
```
