# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

This is a personal homelab repository for a Kubernetes cluster using Talos Linux and various Terraform projects to manage related infrastructure.

### Repo structure

- `k8s/`: Manifests for flux-cd in my Kubernetes cluster
- `terraform/`: OpenTofu projects for infrastructure not in the Kubernetes cluster
- `talos/`: Configuration for Talos Linux, the OS installed on Kubernetes nodes
- `hack/`: one-off scripts

## Commands

- `mise run flux-test`: validate that every Flux Kustomization and HelmRelease renders
- `mise run flux-build <name>`: render a single Flux Kustomization to YAML, e.g. `mise run flux-build home-assistant`
- `mise run flux-diff`: diff the rendered manifests against `master`
- `tofu fmt -check`: check Terraform formatting

## Conventions

- Always follow the [Conventional Commits](https://www.conventionalcommits.org/) specification
- Secrets are stored in 1Password and referenced by: the external-secrets operator in Kubernetes, the `onepassword_item` data resource in Terraform, and the `op` 1Password CLI in scripts
- The filename for resources deployed by flux should match the Kubernetes object in all lower case, e.g. `OCIRepository` in `ocirepository.yaml`
- Every YAML file starts with `---` and a `# yaml-language-server: $schema=...` line
- Tools required to run commands are pinned in `mise.toml`

## PR Reviews

### Kubernetes

- Ensure the flate diff comment matches the expected changes
- Resource requests and limits should be specified
- Prefer ghcr.io as the container registry
- If the `Kustomization` depends on an existing one, it should be specified in the `.spec.dependsOn`
- `flate test all` must pass

### Terraform

- Secrets must be ephemeral resources if supported
- `tofu fmt -check` must pass
