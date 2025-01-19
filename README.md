# MyHomelab
Here is i store the state of my homelab

## Prerequisite

You are running on *linux* or running in a *linux wsl* environment.

To setup your environment we have depend on `nix-shell` to have an isolated environment and all required tools pre installed

To install `nix-shell` open a terminal and run the following command 

```bash
sh <(curl -L https://nixos.org/nix/install) --no-daemon 
```

## Getting Started

Open a bash terminal and run the follwing commands

## Setup environment
this will install the following tools in the nix environment

- git
- kubectl
- k9s
- fluxcd
- minikube

```bash
nix-shell
```

## Start local kubernetes cluster

```bash
minikube start
```

## Flux CD Gitops

Create a [GitHub Token](https://github.com/settings/tokens?type=beta) With the following permissions

- **Administration** - Read and write
- **Commit statuses** - Read and write
- **Contents** - Read and write
- **Metadata** - Read-only 
- **Pull requests** - Read and write

Set the token with the following command

```bash
export GITHUB_TOKEN=<GITHUB TOKEN>
export ENVIRONMENT=local

flux bootstrap github \
    --token-auth \
    --owner=pmdevers \
    --repository=MyHomelab \
    --branch=main \
    --path=clusters/$ENVIRONMENT \
    --personal \
    --components-extra image-reflector-controller,image-automation-controller
```

> [!WARNING]  
> For ingress to start working en open a connection run the following command.  
> `minikube tunnel &`
