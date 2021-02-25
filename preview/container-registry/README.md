# Container-Registry related tasks

- [icr-containerize](#build-image-helper-task:-icr-containerize): this task builds and pushes an image to the [IBM Cloud Container Registry](https://cloud.ibm.com/docs/services/Registry?topic=registry-getting-started). This task relies on [Buildkit](https://github.com/moby/buildkit) to perform the build of the image.
- [icr-cr-build](#build-image-helper-task:-icr-cr-build): this task builds and pushes an image to the [IBM Cloud Container Registry](https://cloud.ibm.com/docs/services/Registry?topic=registry-getting-started). This task relies on [IBM Cloud Container Registry](https://cloud.ibm.com/docs/services/Registry?topic=registry-getting-started) `build` command to perform the build of the image.
- [icr-execute-in-dind](#docker-in-docker-(dind)-helper-task:-icr-execute-in-dind): this task runs `docker` commands (build, inspect...) against a Docker engine running as a sidecar container, and pushes the resulting image to the [IBM Cloud Container Registry](https://cloud.ibm.com/docs/services/Registry?topic=registry-getting-started).
- [icr-check-va-scan](#vulnerability-advisor-helper-task:-icr-check-va-scan): this task verifies that a [Vulnerability Advisor scan](https://cloud.ibm.com/docs/services/Registry?topic=va-va_index) has been made for the image and processes the outcome of the scan.
- [icr-check-dockerfile](#check-dockerfile:-icr-check-dockerfile): this task runs [dockerlint](https://github.com/redcoolbeans/dockerlint) for the given docker file.


**WARNING: These tasks needs to run on Kubernetes cluster with minimal version 1.16. If you are using your own Delivery Pipeline Private Worker to run your tekton pipeline(s), ensure your cluster is updated to this version at least.**

## Install the Tasks
- Add a github integration to your toolchain with the repository containing the tasks (https://github.com/open-toolchain/tekton-catalog)
- Add this github integration to the Definitions tab of your Continuous Delivery tekton pipeline, with the Path set to `container-registry`

## Build Image helper task: icr-containerize

### Context - ConfigMap/Secret

  The task expects the following kubernetes resources to be defined:

* **Secret cd-secret**

  Secret containing:
  * **API_KEY**: An [IBM Cloud Api Key](https://cloud.ibm.com/iam/apikeys) used to access to the IBM Cloud Container registry service.

  See this [sample TriggerTemplate](./sample/listener-containerize.yaml) on how to create the secret using `resourcetemplates` in a `TriggerTemplate`

### Parameters

* **image-url** : (optional) the url of the image to build - required if no image pipeline resource provided to this task
* **path-to-context**: (optional) the path to the context that is used for the build (default to `.` meaning current directory)
* **path-to-dockerfile**: (optional) the path to the Dockerfile that is used for the build (default to `.` meaning current directory)
* **buildkit-image**: (optional) The name of the BuildKit image used (default to `moby/buildkit:v0.6.3-rootless`)
* **additional-tags**: (optional) comma-separated list of tags for the built image
* **additional-tags-script**: (optional) Shell script commands that will be invoked to provide additional tags for the build image
* **properties-file**: (optional) name of the properties file that will be created (if needed) or updated (if existing) as an additional outcome of this task in the pvc. This file will contains the image registry-related information (`REGISTRY_URL`, `REGISTRY_NAMESPACE`, `REGISTRY_REGION`, `IMAGE_NAME`, `IMAGE_TAGS` and `IMAGE_MANIFEST_SHA`)
* **resource-group**: (optional) target resource group (name or id) for the ibmcloud login operation
* **retry-count**: (Default: `5`) retry count to try kubectl commands
* **retry-delay**: (Default: `10`) the amount of seconds between the retries

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

### Results

* **image-tags**: the tags for the built image
* **image-digest**: the image digest (sha-256 hash) for the built image

### Workspaces

* **source**: A workspace containing the source (Dockerfile, Docker context) to create the image

## Build Image helper task: icr-cr-build

### Context - ConfigMap/Secret

  The task expects the following kubernetes resources to be defined:

* **Secret cd-secret**

  Secret containing:
  * **API_KEY**: An [IBM Cloud Api Key](https://cloud.ibm.com/iam/apikeys) used to access to the IBM Cloud Container registry service.

  See this [sample TriggerTemplate](./sample/listener-containerize.yaml) on how to create the secret using `resourcetemplates` in a `TriggerTemplate`

### Parameters

* **image-url** : (optional) the url of the image to build - required if no image pipeline resource provided to this task
* **path-to-context**: (optional) the path to the context that is used for the build (default to `.` meaning current directory)
* **path-to-dockerfile**: (optional) the path to the Dockerfile that is used for the build (default to `.` meaning current directory)
* **additional-tags**: (optional) comma-separated list of tags for the built image
* **additional-tags-script**: (optional) Shell script commands that will be invoked to provide additional tags for the build image
* **properties-file**: (optional) name of the properties file that will be created (if needed) or updated (if existing) as an additional outcome of this task in the workspace. This file will contains the image registry-related information (`REGISTRY_URL`, `REGISTRY_NAMESPACE`, `REGISTRY_REGION`, `IMAGE_NAME`, `IMAGE_TAGS` and `IMAGE_MANIFEST_SHA`)
* **resource-group**: (optional) target resource group (name or id) for the ibmcloud login operation
* **retry-count**: (Default: `5`) retry count to try ibmcloud commands
* **retry-delay**: (Default: `10`) the amount of seconds between the retries

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

### Results

* **image-tags**: the tags for the built image
* **image-digest**: the image digest (sha-256 hash) for the built image

### Workspaces

* **source**: A workspace containing the source (Dockerfile, Docker context) to create the image

## Docker In Docker (DIND) helper task: icr-execute-in-dind
This task runs `docker` commands (build, inspect...) that communicate with a sidecar dind,
and pushes the resulting image to the IBM Cloud Container Registry.

**Note:** the **Docker engine** used to execute the commands is **transient**, created by the task as a sidecar container,
and is available only during the task's lifespan.

#### Context - ConfigMap/Secret

  The task expects the following kubernetes resources to be defined:

* **Secret cd-secret**

  Secret containing:
  * **API_KEY**: An [IBM Cloud Api Key](https://cloud.ibm.com/iam/apikeys) used to access to the IBM Cloud Container registry service.

  See this [sample TriggerTemplate](./sample-docker-dind-sidecar/listener-docker-in-docker.yaml) on how to create the secret using `resourcetemplates` in a `TriggerTemplate`

### Parameters

* **image-url** : (optional) the url of the image to build - required if no image pipeline resource provided to this task
* **image-tag**: (optional) the tag for the built image (default to `latest`)
* **path-to-context**: (optional) the path to the context that is used for the build (default to `.` meaning current directory)
* **path-to-dockerfile**: (optional) the path to the Dockerfile that is used for the build (default to `.`)
* **dockerfile**: (optional) the name of the Dockerfile that is used for the build (default to `Dockerfile`)
* **docker-client-image**: (optional) The Docker image to use to run the Docker client (default to `docker`)
* **properties-file**: (optional) name of the properties file that will be created (if needed) or updated (if existing) as an additional outcome of this task in the workspace. This file will contains the image registry-related information (`REGISTRY_URL`, `REGISTRY_NAMESPACE`, `IMAGE_NAME`, `IMAGE_TAGS` and `IMAGE_MANIFEST_SHA`)
* **docker-commands**: (optional) The docker command(s) to run. Default commands:
  ```
  docker build --tag "$IMAGE_URL:$IMAGE_TAG" --file $PATH_TO_DOCKERFILE/$DOCKERFILE $PATH_TO_CONTEXT
  docker inspect ${IMAGE_URL}:${IMAGE_TAG}
  docker push ${IMAGE_URL}:${IMAGE_TAG}
  ```

### Results

* **image-tags**: the tags for the built image
* **image-digest**: the image digest (sha-256 hash) for the built image

### Workspaces

* **source**: A workspace containing the source (Dockerfile, Docker context) to create the image

## Docker In Docker (DIND) Kubernetes Cluster Hosted helper task: icr-execute-in-dind-cluster
This task runs `docker` commands (build, inspect...) that communicate with a docker dind instance hosted in a kubernetes cluster (eventually deploying the Docker DinD if needed), and pushes the resulting image to the IBM Cloud Container Registry.

#### Context - ConfigMap/Secret

  The task expects the following kubernetes resources to be defined:

* **Secret cd-secret**

  Secret containing:
  * **API_KEY**: An [IBM Cloud Api Key](https://cloud.ibm.com/iam/apikeys) used to access to the IBM Cloud Container registry service.

  See this [sample TriggerTemplate](./sample-docker-dind-cluster/listener-docker-dind-cluster.yaml) on how to create the secret using `resourcetemplates` in a `TriggerTemplate`

### Parameters

* **resource-group**: (optional) target resource group (name or id) for the ibmcloud login operation
* **cluster-region**: (optional) the ibmcloud region hosting the cluster (if value is `` it will default to the toolchain region)
* **cluster-namespace**: (optional) the kubernetes cluster namespace where the docker engine is hosted/deployed (default to `build`)
* **cluster-name**: (optional) name of the docker build cluster - required if no cluster pipeline resource provided to this task
* **image-url** : (optional) the url of the image to build - required if no image pipeline resource provided to this task
* **image-tag**: (optional) the tag for the built image (default to `latest`)
* **path-to-context**: (optional) the path to the context that is used for the build (default to `.` meaning current directory)
* **path-to-dockerfile**: (optional) the path to the Dockerfile that is used for the build (default to `.`)
* **dockerfile**: (optional) the name of the Dockerfile that is used for the build (default to `Dockerfile`)
* **docker-client-image**: (optional) The Docker image to use to run the Docker client (default to `docker`)
* **properties-file**: (optional) name of the properties file that will be created (if needed) or updated (if existing) as an additional outcome of this task in the workspace. This file will contains the image registry-related information (`REGISTRY_URL`, `REGISTRY_NAMESPACE`, `IMAGE_NAME`, `IMAGE_TAGS` and `IMAGE_MANIFEST_SHA`)
* **docker-commands**: (optional) The docker command(s) to run. Default commands:
  ```
  docker build --tag "$IMAGE_URL:$IMAGE_TAG" --file $PATH_TO_DOCKERFILE/$DOCKERFILE $PATH_TO_CONTEXT
  docker inspect ${IMAGE_URL}:${IMAGE_TAG}
  docker push ${IMAGE_URL}:${IMAGE_TAG}
  ```

### Results

* **image-tags**: the tags for the built image
* **image-digest**: the image digest (sha-256 hash) for the built image

### Workspaces

* **source**: A workspace containing the source (Dockerfile, Docker context) to create the image

## (DEPRECATED) Vulnerability Advisor helper task: icr-check-va-scan

### Context - ConfigMap/Secret

  The task expects the following kubernetes resources to be defined:

* **Secret cd-secret**

  Secret containing:
  * **API_KEY**: An [IBM Cloud Api Key](https://cloud.ibm.com/iam/apikeys) used to access to the IBM Cloud Container registry service.

  See this [sample TriggerTemplate](./sample/listener-containerize.yaml) on how to create the secret using `resourcetemplates` in a `TriggerTemplate`

### Parameters

* **image-url**: (optional) url of the image to VA scan - required if no image pipeline resource provided to this task
* **image-digest**: (optional) SHA id of the image to VA scan - required if no image pipeline resource provided and no `image-properties-file` value provided
* **image-properties-file**: file containing properties of the image to be scanned (default to 'build.properties')
* **max-iteration**: maximum number of iterations allowed while loop to check for va report (default to 30 iterations maximum)
* **sleep-time**: sleep time (in seconds) between invocation of ibmcloud cr va in the loop (default to 10 seconds between scan result inquiry)
* **scan-report-file**: (optional) filename for the scan report (json format) of the given image. It will be copied in the workspace
* **fail-on-scanned-issues**: flag (`true` | `false`) to indicate if the task should fail or continue if issues are found in the image scan result (default to 'true')
* **resource-group**: (optional) target resource group (name or id) for the ibmcloud login operation
* **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
* **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name
* **retry-count**: (Default: `5`) retry count to try ibmcloud commands
* **retry-delay**: (Default: `10`) the amount of seconds between the retries

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable\

### Results

* **scan-report-file**: the filename if the scan report for the image stored in the workspace
* **scan-status**: the status from Vulnerability Advisor - possible values: OK, WARN, FAIL, UNSUPPORTED, INCOMPLETE, UNSCANNED

### Workspaces

* **artifacts**: Workspace that may contain image information and will have the va report from the VA scan after this task execution

### Resources

#### Inputs

* **image**: (optional) The Image PipelineResource that this task will process the Vulnerability Advisor scan result.

## Usages

- The `sample` sub-directory contains an `event-listener-container-registry` EventListener definition that you can include in your tekton pipeline configuration to run an example usage of the `icr-containerize` and `icr-check-va-scan`.
  It also contains a `buildkit-no-resources` EventListener definition which is the providing the same example but without the needs to define PipelineResources for image as it uses the task's parameter `image-url` to provide the information

  See the documentation [here](./sample/README.md)

- The `sample-cr-build` sub-directory contains an `cr-build` EventListener definition that you can include in your tekton pipeline configuration to run an example usage of the `icr-cr-build` and `icr-check-va-scan`.
  It also contains a `cr-build-no-resources` EventListener definition which is the providing the same example but without the needs to define PipelineResources for image as it uses the task's parameter `image-url` to provide the information.

  See the documentation [here](./sample-cr-build/README.md)

- The `sample-docker-dind-sidecar` sub-directory contains an `event-listener-dind` EventListener definition that you can include in your Tekton pipeline configuration to run an example usage of the `icr-execute-in-dind` and `icr-check-va-scan`.
  It also contains a `dind-no-resources` EventListener definition which is the providing the same example but without the needs to define PipelineResources for image as it uses the task's parameter `image-url` to provide the information

  See the documentation [here](./sample-docker-dind-sidecar/README.md)

- The `sample-docker-dind-cluster` sub-directory contains an `event-listener-dind-cluster` EventListener definition that you can include in your Tekton pipeline configuration to run an example usage of the `icr-execute-in-dind-cluster` and `icr-check-va-scan`.
  It also contains a `dind-cluster-no-resources` EventListener definition which is the providing the same example but without the needs to define PipelineResources for image as it uses the task's parameter `image-url` to provide the information

  See the documentation [here](./sample-docker-dind-cluster/README.md)


## Check Dockerfile: icr-check-dockerfile

This task runs [dockerlint](https://github.com/redcoolbeans/dockerlint) for the given docker file.

### Inputs

#### Parameters

- **path-to-dockerfile**: (Default to `/artifacts`) The path to the Dockerfile that is used for the build
- **dockerfile**: (Default to `Dockerfile`) The name of the Dockerfile that is used for the build
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
- **app-directory**: The path of the application we use

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks


### Usage
```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pipeline
spec:
  params:
    - name: app-directory
  workspaces:
    - name: artifacts
  tasks:
    - name: check-dockerfile
      taskRef:
        name: icr-check-dockerfile
      workspaces:
        - name: artifacts
          workspace: artifacts
      params:
        - name: app-directory
          value: $(params.app-directory)
```
