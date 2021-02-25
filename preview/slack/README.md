# Post to Slack task helper: slack-post-message
This Task posts a message to the Slack channel(s) integrated with your [Continuous Delivery toolchain](https://cloud.ibm.com/docs/services/ContinuousDelivery?topic=ContinuousDelivery-integrations#slack).

The task retrieves a Slack integration(s) from the Toolchain,
filtered on the Slack domain (if passed as a parameter) and posts the message to the corresponding channel(s).

The message can be:
- passed as a parameter
   - a static Slack formatted JSON payload
   - a static text message (that will be converted to Slack JSON payload)
- dynamically injected
   - by a script
   - based on the output of previous task(s) stored in the PVC
- default message if not set

    ![Default value](https://github.ibm.com/one-pipeline/docs/blob/master/assets/common-tekton-tasks/slack/default-message.png)

## Prerequisites
### Slack
Create a [Slack Webhook](https://api.slack.com/messaging/webhooks).
### Toolchain
Add a [Slack integration](https://cloud.ibm.com/docs/services/ContinuousDelivery?topic=ContinuousDelivery-integrations#slack) to your [Continuous Delivery toolchain](https://cloud.ibm.com/docs/services/ContinuousDelivery?topic=ContinuousDelivery-toolchains-using)
## Install the Task
- Add a github integration in your Toolchain to the repository containing the task (https://github.com/open-toolchain/tekton-catalog)
- Add that github integration to the Definitions tab of your Continuous Delivery Tekton pipeline, with the Path set to `slack`.

### Parameters

* **base-image**: (optional, default: `icr.io/continuous-delivery/pipeline/pipeline-base-image:2.6@sha256:7f588468622a981f89cf5e1212aaf75fface9da6169b5345ca52ab63d8215907`) the base image to use for running this Task. Make sure that the base image has `bash` and `shell` and the appropriate interpreter for the `message-script` parameter.
* **domain**: (optional) the Slack domain to send the message to. If not set, the message will be posted to the Slack integration(s) as defined in the Toolchain.
* **channel**: (optional) the Slack channel to send the message to. When set, overrides the default channel as set in the Slack Webhook URL.
* **message-format**: (optional) the format of the message. Value: text(default) or JSON.
* **message-script**: (optional) Script that provides messsage content.
  * Supported bang-lines by the default base-image:
    * Node: `#!/usr/bin/env node`
    * Python3: `#!/usr/bin/env python3`
    * Shell: `#!/bin/sh` (default - if you don't start your script with a bangline, Shell will be used)
    * Bash: `#!/bin/bash`
* **message**: (optional) the message to send to Slack.
* **exit-on-error**: flag (`true` | `false`) to indicate if the task should fail or continue if unable to process the message or post to Slack (default `false`).

## Workspaces

* **workspace**: A workspace that contain data useful for the script/slack message resolution. Should be marked as optional when Tekton will permit it.

## Outputs
None.

## Usage
The `sample` sub-directory contains an EventListener and Pipeline definition that you can include in your Tekton pipeline configuration to run an example of the `slack-post-message` task.

1) Create or update a Toolchain so it includes:
   - a Slack integration
   - the repository containing this tekton task
   - a Tekton pipeline definition

   ![Toolchain overview](https://github.ibm.com/one-pipeline/docs/blob/master/assets/common-tekton-tasks/slack/sample-toolchain-overview.png)

2) Add the definitions of this task and the sample (`slack` and `slack/sample` paths)

   ![Tekton pipeline definitions](https://github.ibm.com/one-pipeline/docs/blob/master/assets/common-tekton-tasks/slack/sample-tekton-pipeline-definitions.png)

3) Add the environment properties as needed:

   - `domain` (optional) the Slack domain to send the message to.
   - `channel` (optional) the channel to post to (overrides the dafault channel as set in the Slack webhook).
   - `message-format` (optional) the format of the message (text or JSON).
   - `message-script` (optional) Script that provides messsage content.
   - `message` (optional) the message to post to Slack.

**Note:** when using JSON format, the message is posted as-is to Slack.

   ![Tekton pipeline environment properties](https://github.ibm.com/one-pipeline/docs/blob/master/assets/common-tekton-tasks/slack/sample-tekton-pipeline-environment-properties.png)


1) Create a manual trigger to start the sample listener

   ![Tekton pipeline sample trigger](https://github.ibm.com/one-pipeline/docs/blob/master/assets/common-tekton-tasks/slack/sample-tekton-pipeline-sample-triggers.png)

2) Run the pipeline

3) The message is posted to Slack

   ![sample message](https://github.ibm.com/one-pipeline/docs/blob/master/assets/common-tekton-tasks/slack/sample-message.png)

4) Optional: check the execution log

   ![Tekton pipeline sample trigger](https://github.ibm.com/one-pipeline/docs/blob/master/assets/common-tekton-tasks/slack/sample-log.png)

5) Optionnal: Create a message using snippet

   a) Define the snippet in the `message-script` environment property of the pipeline

       message-script: `echo 'Message sent from PipelineRun' ${PIPELINE_RUN_NAME}; echo 'uid:' ${PIPELINE_RUN_ID}; echo 'buildNumber:' ${BUILD_NUMBER};`

       message-script: `!#/usr/bin/env node \n console.log('This Comes from NodeJS');`

      Note: this could also be done in the trigger-template or pipeline definition

      ![Tekton pipeline sample trigger](https://github.ibm.com/one-pipeline/docs/blob/master/assets/common-tekton-tasks/slack/sample-snippet-environment-property.png)


   b) After running the pipeline, a new message like the following should have been posted to the Slack channel

      ![sample message using snippet](https://github.ibm.com/one-pipeline/docs/blob/master/assets/common-tekton-tasks/slack/sample-snippet-message.png)

   c) Check the execution log

      ![Tekton pipeline sample snippet message](https://github.ibm.com/one-pipeline/docs/blob/master/assets/common-tekton-tasks/slack/sample-snippet-log.png)
