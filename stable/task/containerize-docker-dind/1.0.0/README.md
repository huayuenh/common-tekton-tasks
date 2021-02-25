# containerize-docker-dind v1.0.0 (DEPRECATED)

Task to build, tag and push a docker image to the ibmcloud cr registry, using DIND docker.

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```

### Inputs

#### Parameters

 - **continuous-delivery-context-secret**:  name of the Secret containing the continuous delivery pipeline context secrets (Default: `secure-properties`)
 - **continuous-delivery-context-environment**:  Name of the ConfigMap containing the continuous delivery pipeline context environment properties (Default: `environment-properties`)
 - **container-registry-apikey-secret-key**:  field in the secret that contains the api key used to login to ibmcloud container registry (Default: `apikey`)
 - **properties-file**: file containing properties out of the docker in docker task (Default: `build.properties`)
 - **ibmcloud-api**:  the ibmcloud api (Default: `https://cloud.ibm.com`)
 - **pipeline-debug**:  Pipeline debug mode (Default: `"0"`)


**Registry related parameters**

 - **resource-group**:  target resource group (name or id) for the ibmcloud login operation (Default: `""`)
 - **registry-create-namespace**:  create container registry namespace if it doesn't already exists (Default: `"true"`)
 - **registry-region**:  container registry region id. required if no image-url or no image pipeline resources provided (Default: `""`)
 - **registry-namespace**:  container registry namespace. required if no image-url or no image pipeline resources provided (Default: `""`)

**Image related parameters**

 - **image-url**: URL of the image to build. Required if no image pipeline resource provided or no registry region, namespace and image name parameters are provided to this task (Default: `""`)
 - **image-name**: Image name. Required if no image-url or no image pipeline resources provided (Default: `""`)
 - **image-tags**: Optional tags for the image to be build. (Default: `""`)
 - **tags-script**: Shell script that allows to calculate tags for the image to be build.
 Default script:
 ```
    # The script is providing tag(s) as output
    # But logs can be written as error stderr
    echo "Providing an image tag including git branch and commit" >&2
    # Add a specific tag with branch and commit
    echo "$(date +%Y%m%d%H%M%S)-$(tasks.code-fetch-code.results.git-branch)-$(tasks.code-fetch-code.results.git-commit)"

 ```

**Dockerfile location**

 - **path-to-context**: Path to the workingdir to build in (Default: `.`)
 - **path-to-dockerfile**: Path to the Docker file (Default: `.`)
 - **dockerfile**: Name of the Dockerfile (Default: `"Dockerfile"`)

**Docker Client configuration**

 - **docker-client-image**:  The Docker image to use to run the Docker client (Default: `docker`)

**Docker commands**

 - **docker-commands**:  The docker command(s) to run.
Default script:
```
    # Default docker build / inspect / push command
    docker build --tag "$IMAGE_URL:$IMAGE_TAG" --file $PATH_TO_DOCKERFILE/$DOCKERFILE $PATH_TO_CONTEXT
    docker inspect ${IMAGE_URL}:${IMAGE_TAG}
    docker push ${IMAGE_URL}:${IMAGE_TAG}

```

#### Implicit / data from the pipeline

**Base image pulls secrets (optional)**

To provide pull credentials for the base image you use in your Dockerfile, for example for a UBI image from Red Hat registry, add these variables to your pipeline on he pipeline UI. The Task will look for them and if they are present, it will add an entry to the proper `config.json` for docker.

- **build-baseimage-auth-user** The username to the registry (Type: `text`)
- **build-baseimage-auth-password** The password to the registry (Type: `SECRET`)
- **build-baseimage-auth-host** The registry host name (Type: `text`)
- **build-baseimage-auth-email** An email address to the registry account (Type: `text`)

#### Dependencies

- **[stable/configmap/image-registry-scripts/1.0.0](../../../configmap/image-registry-scripts/1.0.0)** ConfigMap with helper scripts for registry related tasks
- **toolchain** ConfigMap with the information on the current toolchain in a JSON format

#### Workspaces

 - **source**: A workspace containing the source (Dockerfile, Docker context) to create the image


### Outputs

#### Results

* **image-repository**: Image respository URL (`registry_url/namespace/image_name`)
* **image-tags**: Tags for the built image
* **image-digest**: Image digest (sha-256 hash) for the built image

### Usage

Example usage in a pipeline.

``` yaml

  - name: build-containerize
    taskRef:
      name: containerize-docker-dind
    runAfter:
      - code-check-dockerfile
    workspaces:
      - name: source
        workspace: artifacts
    params:
      - name: registry-region
        value: $(params.registry-region)
      - name: registry-namespace
        value: $(params.registry-namespace)
      - name: image-name
        value: $(params.app-name)
      - name: tags-script
        value: |
          # The script is providing tag(s) as output
          # But logs can be written as error stderr
          echo "Providing an image tag including git branch and commit" >&2
          # Add a specific tag with branch and commit
          echo "$(date +%Y%m%d%H%M%S)-$(tasks.code-fetch-code.results.git-branch)-$(tasks.code-fetch-code.results.git-commit)"
          echo "latest"

      - name: docker-commands
        value: |
          # Default docker build / inspect / push command
          docker build ${IMAGE_TAGS} --file $PATH_TO_DOCKERFILE/$DOCKERFILE $PATH_TO_CONTEXT
          docker inspect ${IMAGE_URL}
          docker push ${IMAGE_URL}

      - name: container-registry-apikey-secret-key
        value: api-key
      - name: path-to-context
        value: "$(tasks.code-fetch-code.results.directory-name)"
      - name: path-to-dockerfile
        value: "./$(tasks.code-fetch-code.results.directory-name)"
      - name: properties-file
        value: ""
      - name: pipeline-debug
        value: $(params.pipeline-debug)

```
