# KubeDoctor

KubeDoctor is Kubernetes flow controller for macOS.

![main-controller](assets/main-controller.png)

## Feature

* Custom action for resources
* Fast Editor
* Resources first

![main-controller](assets/editor.png)

## Getting Started

Create a configuration file `vim ~/.kube/kd.yml`
```yaml
version: 1
resourcesKind:
  # 模式，这个暂时未实现，是根据过滤模式列出关心的资源
  mode: ""
  list: ["pods", "deployments.app"]
rightMenus:
  common:
    - name: "概述"
      script: "kubectl describe {{ data.kind }} {{ data.metadata.name }} -n {{ data.metadata.namespace }} --context {{ context }}"
      # action 支持复制到剪切板和直接运行
      # clipboard: 复制到剪切板
      # shell: 直接运行
      action: clipboard
    - name: "编辑"
      script: "{{ kubectl }} get {{ data.kind }} {{ data.metadata.name }} -o yaml -n {{ data.metadata.namespace }} --context {{ context }} > ${TMPDIR}/{{ data.metadata.name }}.yaml && /usr/local/bin/code ${TMPDIR}/{{ data.metadata.name }}.yaml"
      action: shell
    - name: "删除"
      script: "kubectl delete {{ data.kind }} {{ data.metadata.name }} -n {{ data.metadata.namespace }} --context {{ context }}"
      action: clipboard
  Kind:
  - name: pods
    group:
      - - name: "日志"
          script: "kubectl logs {{ data.metadata.name }} -n {{ data.metadata.namespace }} --context {{ context }} -f --tail 300"
          action: clipboard
```
