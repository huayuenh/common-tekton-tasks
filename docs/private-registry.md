### Using an image from a private registry

1. [Get token](https://taas.w3ibm.mybluemix.net/guides/create-apikey-in-artifactory.md) from TaaS [Artifactory](https://eu.artifactory.swg-devops.com/artifactory/webapp/#/home).

2. [Create](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line) a docker registry secret.
```sh
kubectl create secret docker-registry regcred \
--docker-server=wcp-compliance-automation-team-docker-local.artifactory.swg-devops.com  \
--docker-username=<YOUR-IBM-EMAIL> \
--docker-password=<YOUR-API-KEY> \
--docker-email=<YOUR-IBM-EMAIL>
```

3. [Export secret as `YAML`](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#inspecting-the-secret-regcred) and insert into tekton definitions.

```yaml
- apiVersion: v1
      kind: Secret
      data:
        .dockerconfigjson: <BASE64-ENCODED-DOCKERCONFIG>
      metadata:
        name: <PULL-SECRET-NAME>
      type: kubernetes.io/dockerconfigjson
```

4. Define a `ServiceAccount`
``` yaml
- apiVersion: v1
      kind: ServiceAccount
      imagePullSecrets:
      - name: <PULL-SECRET-NAME>
      metadata:
        name: sa-pullsecret 
```

5. Use the `ServiceAccount` in the `PipelineRun`
```yaml
 - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        name: pipelinerun-$(uid)
      spec:
        pipelineRef:
            name: example-pipeline
        params:                    
          - name: repository
            value: $(params.repository)
          - name: revision
            value: $(params.revision)
        serviceAccounts: 
          - taskName: pipeline-custom-task
            serviceAccount: sa-pullsecret
```
