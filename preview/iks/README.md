# IBM Kubernetes Service
Tasks for IKS

#### Tasks

- [iks-fetch-config](#iks-fetch-config)
- [iks-deploy](#iks-deploy)
- [iks-contextual-execution](#iks-contextual-execution)
- [iks-create-namespace](#iks-create-namespace)
- [iks-create-pull-secrets](#iks-create-pull-secrets)


## iks-fetch-config
Fetch IKS cluster config

### Inputs

#### Parameters

 - **cluster-name**: the targeted cluster
 - **cluster-region**: region of targeted cluster
 - **ibmloud-api**: (Default: `https://cloud.ibm.com`)the IBM cloud API endpoint
 - **cluster-pipeline-resources-directory-fallback**: (Default: `.tekton-cluster-pipeline-resources`) directory in the workspace that will be used as a fallback mechanism to store the kubeconfig file
 - **kube-api-server-accessible**: (Default: `false`) indicates if the kubeAPIServer is exposed which is not the case for IBM Cloud Public Shared Workers (Calico network policy). If 'true', the task is trying to update the Cluster Pipeline Resources definition with the appropriate information. When 'false', the fallback mechanism (copy file(s)) is used.
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
 - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
 - **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `30`) the amount of seconds between the retries
 - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

- **retry_command.sh**: used to retry specific parts of a task, which are not stable


#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks


## iks-deploy

Deploy to a given cluster

### Inputs

#### Parameters

- **cluster-name**: The IBM Cloud cluster name
- **cluster-region**: The IBM Cloud region for your cluster
- **cluster-namespace**: (Default: `default`) The IBM Cloud cluster namespace
- **ibmcloud-api**: (Default: `https://cloud.ibm.com`) the ibmcloud api endpoint
- **deployment-file**: (Default: `/artifacts/deployment.yml`) Kubernetes Deployment resource file to use for deploy
- **allow-create-route**:  (Default: `"false"`) Allow the task to create a Route resource (if there is none) to access the deployed app
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
- **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
- **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name
- **image-tag**: (Default: `""`) Tags of the created image, if `image-url` is not provided
- **image-name**: (Default: `""`) Name of the created image, if `image-url` is not provided
- **registry-url**: (Default: `""`) Container registry URL, if `image-url` is not provided
- **registry-namespace**: (Default: `""`) Container registry namespace, if `image-url` is not provided
- **image-url**: (Default: `""`) URL of the created image,  `image-tag` `mage-name`, `registry-url` and `registry-namespace` are parsed from this parameter if they are missing
- **app-directory**: Path of the application

#### Implicit

The following inputs are coming from the `secrets` volume:

- **IBM_CLOUD_API_KEY**: The IBM Cloud API key is used to access the IBM Cloud Kubernetes Service API and interact with the cluster. You can obtain your API key with 'bx iam api-key-create' or via the console at https://cloud.ibm.com/iam#/apikeys by clicking **Create API key** (Each API key only can be viewed once).

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks

#### Resources

- **deployment-file** (Default: "/artifacts/deployment.yml") a Deployment and Service resource yaml in your application repo, that will be applied on the cluster. See the [one-pipeline/hello-compliance-app](https://github.ibm.com/one-pipeline/hello-compliance-app/blob/master/deployment.yml) for example.

### Outputs

#### Results

- **app-url**: The url where the deployed app is available

### Usage
Task usage inside a pipeline

```yaml

    - name: deploy-dev
      taskRef:
        name: iks-deploy
      runAfter:
        - pipeline-1-kubectl-task
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: cluster-name
          value: $(params.cluster-name)
        - name: cluster-region
          value: $(params.registry-region)
        - name: image-tag
          value: $(params.image-tag)
        - name: image-name
          value: $(params.image-name)
        - name: registry-url
          value: $(params.registry-url)
        - name: registry-namespace
          value: $(params.registry-namespace)
        - name: app-directory
          value: $(params.app-directory)
```


## iks-contextual-execution

Executes a user defined script within the context of the kubernetes configuration

### Inputs

#### Parameters

- **cluster-pipeline-resources-directory**: (Default: `/workspace`) directory in which the kubeconfig file(s) for clusterPipelineResources are available
- **script**: (Default: `kubectl version`) the bash snippet to execute
- **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
- **retry-delay**: (Default: `30`) the amount of seconds between the retries
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable


#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks

### Usage
Task usage inside a pipeline

```yaml
    - name: pipeline-1-kubectl-task
      runAfter: [iks-fetch-config]
      taskRef:
        name: iks-contextual-execution
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: cluster-pipeline-resources-directory
          value: /artifacts/.tekton-clusters
        - name: cluster-name
          value: $(params.cluster-name)
        - name: script
          value: |
            echo "** Here is the kubectl version:"
            kubectl version
            echo "** Here is the kubectl cluster-info:"
            kubectl cluster-info
            echo "** Here are the kubectl namespaces:"
            kubectl get namespaces
```

## iks-create-namespace

Creates target namespace if missing.

### Inputs

#### Parameters

- **cluster-name**: The IBM Cloud cluster name
- **cluster-region**: The IBM Cloud region for your cluster
- **cluster-namespace**: (Default: `default`) The IBM Cloud cluster namespace
- **ibmcloud-api**: (Default: `https://cloud.ibm.com`) the ibmcloud api endpoint
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
- **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
- **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
- **retry-delay**: (Default: `20`) the amount of seconds between the retries
- **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks

## iks-create-pull-secrets

Creates image pull secrets into the cluster's namespace if missing.

### Inputs

#### Parameters

- **cluster-name**: The IBM Cloud cluster name
- **cluster-region**: The IBM Cloud region for your cluster
- **cluster-namespace**: (Default: `default`) The IBM Cloud cluster namespace
- **ibmcloud-api**: (Default: `https://cloud.ibm.com`) the ibmcloud api endpoint
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
- **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
- **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name in the secret resource.
- **registry-url**: (Default: `""`) Container registry URL
- **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
- **retry-delay**: (Default: `20`) the amount of seconds between the retries

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

- **retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

- **artifacts**: The output volume to check out and store task scripts & data between tasks

#### Useage
Task usage inside a pipeline.

``` yaml
    - name: prod-create-image-pull-secrets
      taskRef:
        name: iks-create-pull-secrets
      runAfter:
        - prod-create-namespace
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: cluster-name
          value: "cocoa-beta"
        - name: cluster-region
          value: "us-south"
        - name: cluster-namespace
          value: "test-namespace"
        - name: registry-url
          value: $(params.registry-url)
        - name: pipeline-debug
          value: "1"
```
