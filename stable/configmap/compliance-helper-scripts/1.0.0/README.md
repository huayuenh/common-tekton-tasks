# compliance-helper-scripts 1.0.0

Helper scripts for tasks that work with compliance related workflows

### Report a Bug / Request a Feature

If you experience issues, please report them on the following slack channels:
```
#devops-compliance
#common-tekton-tasks
#cd-tekton-users-shared
```


## create_url.sh

Create a precise pipeline run url from the current pipeline run and a provided task name and step name.

#### Parameters

- pipeline_run_url
- task_name
- step_name


#### Return value

The precise URL containing the task and the step

## create_doi_dataset_file.sh

Creates a DOI dataset file that can be used to create custom DOI datasets

#### Parameters

- task_name
- label
- lifecycle_stage

#### Return value

The dataset file path on the workspace

## ibmcloud_doi_update_policy.sh

Update a policy settings and custom datasets using a provided JSON file. The JSON is saved to the `./doi-evidence/` folder in the current working dir.

#### Parameters

- file
- toolchainid

## create_doi_evidence_data.sh

Create a test report from an evidence result for DOI. This step is necessary for evidence reporting to DOI as long as DOI does not support the evidence format directly.

The report JSON is saved to the `./doi-evidence/` folder in the current working dir.

#### Parameters

- title
- result
