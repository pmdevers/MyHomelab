# MyHomelab — Agent Guidelines

## Project Overview

GitOps homelab repository managing two Kubernetes clusters (**local** and **production**) via FluxCD on Talos OS nodes. Infrastructure is fully declarative; all changes go through git.

**Cluster:** 4 nodes — k8s-node-1/2/3 (control-plane), k8s-node-4 (worker)
**Kubeconfig:** `kubeconfig.yaml` at repo root (always pass `--kubeconfig kubeconfig.yaml` or set `KUBECONFIG`)

## Repository Structure

```
applications/     # App manifests, organized by environment
clusters/         # FluxCD bootstrap entry points (dependency chain root)
configuration/    # Cluster-wide config (cert-manager, external-secrets, gateway)
infrastructure/   # Core infrastructure HelmReleases (cilium, GPU operators, NFS, etc.)
talos/            # Talos OS machine config patches (cluster-wide + per-node)
scripts/          # Nushell (.nu) automation scripts
kubeconfig.yaml   # Kubernetes cluster credentials
omniconfig.yaml   # Omni cluster management config
```

## FluxCD Dependency Chain

Changes reconcile in this order (do not break dependencies):

```
infrastructure → configuration → applications
```

Each tier in `clusters/[env]/` references the matching top-level folder via a `Kustomization` CR pointing to the `flux-system` GitRepository (this repo).

## Adding an Application

1. Create `applications/[env]/[app-name]/` with at minimum:
   - `kustomization.yaml` — lists all resources in the folder
   - `namespace.yaml` — Kubernetes Namespace
   - `deployments/` — deployment manifests
2. Add the folder name to `applications/[env]/kustomization.yaml` resources list
3. For external-repo apps, add `gitrepository.yaml`, `image-repository.yaml`, `image-policy.yaml`, `image-automation.yaml`

## Adding an Infrastructure Component

1. Create `infrastructure/[env]/[component-name]/` with:
   - `kustomization.yaml`
   - `namespace.yaml` (set PodSecurity labels if privileged pods needed)
   - `release.yaml` — `HelmRelease` CR
2. Add the HelmRepository source to `infrastructure/[env]/sources/` and register it in `infrastructure/[env]/sources/kustomization.yaml`
3. Add the component to `infrastructure/[env]/kustomization.yaml` resources list

## Naming Conventions

- All folders and Kubernetes resource names: `lowercase-hyphenated`
- Namespace names match the application name
- Talos nodes: `k8s-node-1` … `k8s-node-4`
- Environments: `local`, `production` (never `prod` or `dev`)

## Secrets & External Integrations

- Secrets are managed via **1Password / External Secrets Operator** — never commit plaintext secrets
- Use `ExternalSecret` CRs referencing the `onepassword-connect` store
- Vault address: `http://172.20.10.2:8200` (set via `VAULT_ADDR` in devbox)

## Persistent Storage

- NFS-backed PVCs using `nfs-provisioner`; StorageClass: `nfs`
- Common PVCs: `nfs-config`, `nfs-movies`, `nfs-tv`, `nfs-music`
- For app-specific subpaths on shared PVCs, use `subPath:` in volumeMounts

## Networking

- Ingress via **Gateway API** (`HTTPRoute` resources)
- TLS via **cert-manager** with Let's Encrypt
- CNI: **Cilium** with BGP (Ubiquiti FRR config in `talos/ubiquiti-frr.conf`)

## Hardware

- k8s-node-4: AMD Ryzen 9 7945HX, AMD Radeon 780M iGPU (VAAPI via `/dev/dri/renderD128`)
- AMD GPU Operator installed in `kube-amd-gpu` namespace
- Intel GPU plugin exists in `kube-system` but is irrelevant for k8s-node-4

## Scripting

Scripts use **Nushell** (`.nu`). Do not convert to bash. Key scripts:
- `scripts/environments.nu` — interactive environment selector
- `scripts/fluxcd.nu` — FluxCD bootstrap and reconcile helpers
- `scripts/application.nu` — application management

## Build & Verify

```bash
# Check cluster state
kubectl --kubeconfig kubeconfig.yaml get nodes
kubectl --kubeconfig kubeconfig.yaml get kustomizations -n flux-system

# Force Flux reconciliation
kubectl --kubeconfig kubeconfig.yaml annotate kustomization <name> -n flux-system \
  reconcile.fluxcd.io/requestedAt=$(date -u +%Y-%m-%dT%H:%M:%SZ) --overwrite

# Validate YAML before committing
kubectl --kubeconfig kubeconfig.yaml apply --dry-run=client -f <file>
```

## Conventions

- Always commit changes before expecting Flux to apply them
- Trigger reconciliation after pushing if immediate application is needed
- `prune: true` is set on all Kustomizations — removing a resource from a kustomization.yaml will delete it from the cluster
- Do not edit files inside `clusters/` unless bootstrapping or changing Flux dependency order
