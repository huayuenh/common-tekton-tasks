# <-Task Group Name->
<-Description of the set of tasks->

#### Tasks
- [Sample Task](#<-task-name->)

## <-Task Name->
<-Task description->

### Inputs
<List and describe the inputs for your task>

#### Parameters

- **<-Parameter1->**: <-description->
- **<-Parameter2->**: <-description->

### Outputs

<List and describe outputs>

## Usage

<-Describe usage and give an example->

``` yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: <example>
spec:
  params:
    - name: <example>
      value: <example>
    - name: <example>
      value: <example>
  tasks:
    - name: <example>
      taskRef:
        name: <example>
```

``` yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: <example>
spec:
  inputs:
    resources:
    - name: <example>
      resourceRef:
        name: <example>
  taskRef:
    name: <example>
```
