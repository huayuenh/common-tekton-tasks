# image-registry-scripts v1.0.0

Helper scripts for tasks that work with images, image build and push to registries.

### parse_image_url.sh

Parse the image url to find information (region, namespace, image name and eventually tag) as url of Image PipelineResource is the complete path to the image, including the registry and the image tag

https://github.com/tektoncd/pipeline/blob/v0.10.1/docs/resources.md#image-resource

### check_registry.sh

Run some checks on the targeted IBM Cloud container registry for an image build.

- Create registry namespace if it does not exists
- Check registry quota
