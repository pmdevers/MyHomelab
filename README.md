# MyHomelab
Here is where I store the state of my homelab

## Prerequisite

You are running on *linux* or running in a *linux wsl* environment.

To setup your environment we have depend on `devbox` to have an isolated environment and all required tools pre installed

To install `devbox` open a terminal and run the following command 

```bash
curl -fsSL https://get.jetify.com/devbox | bash
```

## Getting Started

Open a bash terminal and run the follwing commands

## Setup environment
this will install the following tools in the nix environment

- git
- gh
- kubectl
- k9s
- fluxcd
- minikube

```bash
devbox shell
```

## Authentication Token

Create a [GitHub Token](https://github.com/settings/tokens?type=beta) With the following permissions

- **Administration** - Read and write
- **Commit statuses** - Read and write
- **Contents** - Read and write
- **Metadata** - Read-only 
- **Pull requests** - Read and write

## Create environment

```bash
platform setup
```

it will ask to provide the created github token.

## Clean up

to clean up the local environment run the following command

```bash
platform destroy kubernetes
```

# Talos Omni Cluster Patches

This allows scheduling on ControlPlanes
In order for MetalLB to work we need to remove the label `node.kubernetes.io/exclude-from-external-load-balancers`

```yaml
cluster:
  allowSchedulingOnControlPlanes: true
machine:
  nodeLabels:
    node.kubernetes.io/exclude-from-external-load-balancers:
      $patch: delete
```


## Install Cilium

```bash
cilium install \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=true \
  --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --set cgroup.autoMount.enabled=false \
  --set cgroup.hostRoot=/sys/fs/cgroup \
  --set k8sServiceHost=localhost \
  --set k8sServicePort=7445 \
  --set gatewayAPI.enabled=true \
  --set gatewayAPI.enableAlpn=true \
  --set gatewayAPI.enableAppProtocol=true \
  --set l2announcements.enabled=true \
  --set loadBalancer.enabled=true \
  --set loadBalancer.ipam.mode=none \
  --set loadBalancer.mode=snat \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set cluster.name=myhomelab \
```