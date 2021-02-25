# common-tekton-tasks

This repository is an incubator for Common Tekton Task resources, i.e. resources designed to be reusable in other Tekton pipelines. Each Task is categorized into a folder appropriate to the task type (e.g. git tasks) which contains a `README.md` outlining the Task definition. We have provided a [Task template](template) as an aid to ensure a certain base level of consistency.

Our goal is to use this as a centralised repository for collaboration on common Tasks. If you need a Task, maybe it has already been built so check if an issue exists for it. If not you can open a new issue using the Task template. By using a single centralised repo we can reduce the risk of duplicating effort while sharing information efficiently.

## Getting Involved
If you are interested in becoming involved in this initiative and are new to Tekton then this [Tekton tutorial](https://github.com/tektoncd/pipeline/blob/master/docs/tutorial.md#task) can help get you jump started. Or if you want to find out more then feel free to reach out to the community on [this slack channel](https://ibm-cloudplatform.slack.com/archives/CP56J2USY).

## Tasks

**CISO**
- [ciso-image-sign](stable/task/ciso-image-sign/3.0.0)
- [ciso-key-extract](preview/ciso/#ciso-key-extract)

**COMPLIANCE**
- [compliance-check-github-statuses](preview/compliance-checks/#deprecated-compliance-check-github-statuses)
- [compliance-collector](stable/task/compliance-collector/2.1.5)
- [compliance-detect-secrets](stable/task/compliance-detect-secrets/1.0.4)
- [compliance-doi-reporter](stable/task/compliance-doi-reporter/1.1.1)
- [compliance-unit-test](preview/compliance-checks/#deprecated-compliance-unit-test)

**CONTAINER REGISTRY**
- [icr-check-dockerfile](preview/container-registry/#check-dockerfile-icr-check-dockerfile)
- [icr-containerize](preview/container-registry/#build-image-helper-task-icr-containerize)
- [icr-cr-build](preview/container-registry/#build-image-helper-task-icr-cr-build)
- [icr-execute-in-dind](preview/container-registry/#docker-in-docker-dind-helper-task-icr-execute-in-dind)
- [skopeo-copy-image](stable/task/skopeo-copy-image/1.0.1)

**CONTAINERIZE**
- [containerize-check-va-scan](stable/task/containerize-check-va-scan/1.0.2)
- [containerize-docker-dind](stable/task/containerize-docker-dind/1.0.1)

**CRA**
- [cra-bom](stable/task/cra-bom/1.0.2)
- [cra-cis-check](stable/task/cra-cis-check/1.0.2)
- [cra-discovery](stable/task/cra-discovery/1.0.0)
- [cra-vulnerability-remediation](stable/task/cra-vulnerability-remediation/1.0.2)

**DCT**
- [dct-apply-image-enforcement-policy](preview/dct/#dct-apply-image-enforcement-policy)
- [dct-init](preview/dct/#dct-init)
- [dct-sign](preview/dct/#dct-sign)
- [dct-verify](preview/dct/#dct-verify)

**DEVOPS INSIGHTS**
- [devops-insights-publish-build](stable/task/devops-insights-publish-build/1.0.1)
- [devops-insights-publish-test](stable/task/devops-insights-publish-test/1.1.2)
- [devops-insights-publish-deploy](stable/task/devops-insights-publish-deploy/1.1.2)
- [doi-evaluate-gate](preview/devops-insights/#doi-evaluate-gate)

**EVIDENCE**
- [evidence-add](preview/evidence/#evidence-add)
- [evidence-create-incident-issue](preview/evidence/#deprecated-evidence-create-incident-issue)
- [evidence-summarize](stable/task/evidence-summarize/5.2.0)
- [evidence-summary-format](stable/task/evidence-summary-format/1.0.2)
- [evidence-summary-upload](stable/task/evidence-summary-upload/2.1.5)

**GIT**
- [git-clone](stable/task/git-clone/1.0.2)
- [git-clone-inventory-repo](preview/git/#deprecated-git-get-credentials)
- [git-get-credentials](stable/task/git-get-credentials/1.1.1)

**GITHUB**
- [github-check-statuses](stable/task/github-check-statuses/1.0.0)
- [github-create-pull-request](stable/task/github-create-pull-request/2.0.0)
- [github-set-status](stable/task/github-set-status/1.0.1)

**FORTRESS**
- [security-compliance-scan](stable/task/security-compliance-scan/1.0.1)

**IKS**
- [iks-contextual-execution](preview/iks/#iks-contextual-execution)
- [iks-create-namespace](preview/iks/#iks-create-namespace)
- [iks-create-pull-secrets](preview/iks/#iks-create-pull-secrets)
- [iks-deploy](preview/iks/#iks-deploy)
- [iks-fetch-config](preview/iks/#iks-fetch-config)

**INVENTORY**
- [inventory-apply](stable/task/inventory-apply/2.0.2)
- [inventory-conclude](stable/task/inventory-conclude/1.0.1)
- [inventory-cr-add](stable/task/inventory-cr-add/5.0.1)
- [inventory-deployment-bom](stable/task/inventory-deployment-bom/3.0.4)
- [inventory-get](stable/task/inventory-get/1.0.0)
- [inventory-get-pipeline-run-id](preview/inventory#deprecated-inventory-get-pipeline-run-id)
- [inventory-update-version](stable/task/inventory-update-version/1.0.4)

**PIPELINE**

- [pipeline-evaluate](stable/task/pipeline-evaluate/1.0.1)

**SERVICENOW**
- [servicenow-change-state-to-implement](stable/task/servicenow-change-state-to-implement/1.0.0)
- [servicenow-check-change-request-approval](stable/task/servicenow-check-change-request-approval/1.0.0)
- [servicenow-close-change-request](stable/task/servicenow-close-change-request/1.0.3)
- [servicenow-create-change-request](stable/task/servicenow-create-change-request/2.0.2)
- [servicenow-prepare-change-request](stable/task/servicenow-prepare-change-request/7.0.0)

**SLACK**
- [slack-post-message](preview/slack/#post-to-slack-task-helper-slack-post-message)

**STATIC CODE SCAN**
- [static-code-scan-asoc](preview/static-code-scan/#static-code-scan-asoc)

**TEKTON**
- [tekton-lint](stable/task/tekton-lint/1.0.1)

**TERRAFORM**
- [terraform-lint](preview/terraform/#terraform-lint)
- [terraform-config-advisor](preview/terraform/#terraform-config-advisor)

**TOOLCHAIN**
- [toolchain-extract-value](stable/task/toolchain-extract-value/1.0.1)

**UTIL**
- [check-pull-request](stable/task/check-pull-request/1.0.3)
- [util-run](preview/util/#util-run)
- [util-is-equal](stable/condition/is-equal/1.0.0)
- [retry-command](stable/configmap/retry-command/1.0.0)

**YAML**
- [yaml-lint](stable/task/yaml-lint/1.0.0)


## Tasks to be created
ZenHub board link to GIT issues for tasks: [ZenHub board](https://github.ibm.com/one-pipeline/common-tekton-tasks/issues/26#workspaces/one-pipeline-common-tasks-5e42a4baf2028f33235ba945/board?repos=741004&showPRs=false)

The requirement details for each task can be found in its corresponding GIT issue.
If you find that there is a task that you could potentially use in your pipeline, but it does not meet your
requirements, please leave a comment in the issue with your requirements with the aim that the developer will
accommodate them.

Once a task is in a stable enough state to be consumed please add it to the preview folder and open a PR


## Criteria for Code Submission
To ensure code quality, protected branches are enabled, and every PR that is to be merged to master will run CI tasks. These could (and should) be set up for local development environments as well.

Code quality checks currently enabled:
- yaml lint
- tekton task lint


  The pullequests branch is linted against the master branches of [compliance-ci-toolchain](https://github.ibm.com/one-pipeline/compliance-ci-toolchain) and [compliance-cd-toolchain](https://github.ibm.com/one-pipeline/compliance-cd-toolchain).
- enforced commit message conventions (https://www.conventionalcommits.org/en/v1.0.0/)

To be introduced later:
- PR approval check (target branch protection check, approval check)
- linear history check (no merge commits)

To set up these checks locally, run `npm install` in your local working copy.

If you are forking the repository please add the [cocoa-hu user](https://github.ibm.com/cocoa-hu) as a contributor for the forked repository, this user will set the required statuses on the pullrequest.

#### Coding conventions
- kebab-case parameter naming

Example of good naming:
```yaml
spec:
  params:
    - name: task-pvc
    - name: app-repository
    - name: app-branch
```
Examples of wrong naming:

```yaml
spec:
params:
    - name: task_pvc
    - name: appRepository
    - name: AppBranch
```

- start with yaml delimiter `---`
- only one yaml per file

#### Debug capabilities
Tasks must be instrumented for debugging. Task in debug mode can turn on extensive logging, they have to include pieces of code in the right parts.
Debugging should be turned on using the simple environment variable `PIPELINE_DEBUG`. If a pipeline adopter sets the pipeline-debug parameter for a pipeline, it should trigger debugging in several areas.


Each task should include the following code snippets:
- `pipeline-debug` parameter with default value "0"

```yaml
 - name: pipeline-debug
   description: Pipeline debug mode
   default: "0"
```

- `PIPELINE_DEBUG` environment variable, using a step template, to ensure it is available in every step in the task

```yaml
stepTemplate:
  env:
    - name: PIPELINE_DEBUG
      value: $(params.pipeline-debug)
```

- use debugging steps in bash, preferebly after all necessary environment varibles are sourced, but before the script runs
```yaml
if [ $PIPELINE_DEBUG == 1 ]; then
    pwd
    env
    trap env EXIT
    set -x
fi
```


#### Beyond Preview
When a task matures it can be moved from the `preview` folder to the `stable` folder by following [this process](docs/promote-to-stable.md) to ensure quality, integrity etc.

To start a promoting process open a pull request with the promotion template:

```
https://github.ibm.com/one-pipeline/common-tekton-tasks/compare/master…`branch-of-stable-task`?expand=1&template=promotion-template.md
```
where `branch-of-stable-task` is the source branch

### Focal points
- Code committers, e.g. for compliance issues: [Padraic](https://github.ibm.com/padraic-edwards), [Szabolcs](https://github.ibm.com/szabolcsit). For SRE: [Conall](https://github.ibm.com/OCOFAIGH), [Daniel](https://github.ibm.com/DANIELBU).  General: [Community snapshot](https://github.ibm.com/orgs/one-pipeline/people) ...
