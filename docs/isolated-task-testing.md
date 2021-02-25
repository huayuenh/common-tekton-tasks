# Tekton Task testing in isolation

Task development, integration and testing can be time-consuming, sometimes depending on the whole pipeline to work. If a single task fails in the pipeline, the following tasks won't run.


Let's isolate tasks for testing and development. What we need for each task:
- provide inputs (setup)
- check output or result (assert)

We should be able to quickly run these tasks manually, for example using manual triggers for listeners with pre-set parameters.

If a task is updated, this isolated environment can run the task and test it. 

If we have to update the test environment, that means the input or output of the Task was changed, so everyone who use that task will have to update their pipeline as well.

Such an isolated environment can also serve as a living documentation and example on usage of the Task.

## Task Test Pipelines

We've set up a small pipeline for a Task. Can include a _"setup"_ task, to provide optional inputs, like build.properties file on volumes. Also can include an _"assert"_ task, to check results from the Task.

- This pipeline could be triggered manually, with pre-set parameters.
- This pipeline could be set up in user toolchains (even using task-test-pipeline templates?) for development
- This pipeline could be used in local Tekton clusters when they are available

See the pipelines in the folders under `tests`

### New tests

You can use the `setup-test.sh` in the `tests` folder to quickly set up a pipeline for a new task test, based on the template in the `tests/.template` pipeline.

```
$ ./setup-test.sh tested-task-name
```

