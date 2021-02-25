# Docker Content Trust
Tasks for Docker Content Trust

#### Tasks

- [dct-verify](#dct-verify)
- [dct-sign](#dct-sign)
- [dct-init](#dct-init)
- [dct-apply-image-enforcement-policy](#dct-apply-image-enforcement-policy)

## dct-verify
Checks if the required docker image signatures are present

### Inputs

#### Parameters

 - **app-name**: the name of your app
 - **validation-signer**: the validation signer
 - **build-signer**: the build signer
 - **registry-namespace**: the registry namespace
 - **registry-region**: the registry region
 - **image-tags**: tags of the created image
 - **vault-name**: the key protect instance name
 - **resource-group**: the resource group
 - **cluster-name**: the name of the targeted cluster
 - **region**: target region
 - **working-dir**: (Default: `/root`) the working directory
 - **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries
 - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
 - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name
 - **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries


#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

 - **retry_command.sh**: used to retry specific parts of a task, which are not stable

## dct-sign
Signs the provided docker image

### Inputs

#### Parameters

 - **app-name**: the name of your app
 - **validation-signer**: the validation signer
 - **registry-namespace**: the registry namespace
 - **registry-region**: the registry region
 - **image-tags**: tags of the created image
 - **vault-name**: the key protect instance name
 - **resource-group**: the resource group
 - **cluster-name**: the name of the targeted cluster
 - **region**: target region
 - **api-endpoint**: (Default: `https://cloud.ibm.com`)the IBM cloud API endpoint
 - **working-dir**: (Default: `/root`) the working directory
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
 - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
 - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name
 - **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

-**retry_command.sh**: used to retry specific parts of a task, which are not stable

## dct-init
Creates image signing keys for DCT Image Signing tasks, and stores them in Vault

### Inputs

#### Parameters

 - **app-name**: the name of your app
 - **vault-name**: the key protect instance name
 - **region**: target region
 - **cluster-name**: the name of the targeted cluster
 - **registry-namespace**: the registry namespace
 - **registry-region**: the registry region
 - **resource-group**: the resource group
 - **validation-signer**: the validation signer
 - **working-dir**: (Default: `/root`) the working directory
 - **api-endpoint**: (Default: `https://cloud.ibm.com`)the IBM cloud API endpoint
 - **mount-path**: (Default: `/artifacts`) the mount path directory
 - **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries
 - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
 - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

-**retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks

#### Outputs

Stores image signing keys in Vault

## dct-apply-image-enforcement-policy
Applies a cluster policy whereby at deployment time, Kubernetes will enforce a siganture check condition on the specified repo image

### Inputs

#### Parameters

 - **app-name**: the name of your app
 - **vault-name**: the key protect instance name
 - **region**: target region
 - **cluster-name**: the name of the targeted cluster
 - **cluster-namespace**: the targeted namespace of the cluster
 - **registry-namespace**: the registry namespace
 - **registry-region**: the registry region
 - **resource-group**: the resource group
 - **validation-signer**: the validation signer
 - **working-dir**: (Default: `/root`) the working directory
 - **mount-path**: (Default: `/artifacts`) the mount path directory
 - **helm-version** (Default: `2.16.1`) the version of helm being installed
 - **retry-count**: (Default: `5`) retry count to pull and push to the git evidence repo
 - **retry-delay**: (Default: `10`) the amount of seconds between the retries
 - **continuous-delivery-context-secret**: (Default: `secure-properties`) Reference name for the secret resource
 - **ibmcloud-api-key-secret-key**: (Default: `ibmcloud-api-key`) The IBM Cloud API key's secret name

#### Implicit

The following script comes from the [retry-command](../util/configmap-retry.yaml) ConfigMap, which should be included in the pipeline definitions:

-**retry_command.sh**: used to retry specific parts of a task, which are not stable

#### Workspaces

 - **artifacts**: The output volume to check out and store task scripts & data between tasks

#### Dependencies

Pulls scripts from
- https://raw.githubusercontent.com/open-toolchain/commons/master/scripts/
- https://github.com/theupdateframework/notary/releases/download/v0.6.1/notary-Linux-amd64
