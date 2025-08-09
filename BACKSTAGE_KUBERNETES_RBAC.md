# Backstage Kubernetes RBAC Configuration

## Overview

This configuration allows the Backstage service account to read Kubernetes objects across all namespaces with appropriate security permissions.

## Changes Made

### 1. Secure RBAC Configuration (`roles/configure-backstage/files/backstage-rbac.yaml`)

Created a new RBAC configuration file that replaces the overly permissive `cluster-admin` role with a custom `backstage-read-only` ClusterRole that includes:

**Core Resources:**
- Pods, Services, Endpoints, PVs, PVCs, ConfigMaps, Secrets, ServiceAccounts, Nodes, Namespaces

**Application Resources:**
- Deployments, ReplicaSets, StatefulSets, DaemonSets, Jobs, CronJobs, HorizontalPodAutoscalers

**Network Resources:**
- Ingresses, NetworkPolicies

**OpenShift Specific Resources:**
- Routes, ImageStreams, Builds, BuildConfigs

**Custom Resources:**
- Tekton Pipelines, PipelineRuns, Tasks, TaskRuns
- ArgoCD Applications

**Permissions:**
- Only `get`, `list`, and `watch` verbs (read-only access)
- No create, update, delete, or patch permissions

### 2. Updated Ansible Task (`roles/configure-backstage/tasks/main.yml`)

Improved the service account creation process:
- Uses Kubernetes module instead of shell commands for better idempotency
- Creates namespace if it doesn't exist
- Creates service account declaratively
- Applies the secure RBAC configuration
- Generates long-lived token (365 days)

## AAP Pod Exec Permissions

### 3. AAP Exec RBAC Configuration (`roles/configure-aap-controller/files/aap-exec-rbac.yaml`)

Created a separate RBAC configuration for the AAP (Ansible Automation Platform) default service account to allow `oc exec` into pods across the cluster:

**ClusterRole: `aap-pod-exec`**
- **Pod Access**: `get`, `list` permissions on pods
- **Pod Exec**: `create` permission on `pods/exec` and `pods/attach` subresources
- **Pod Logs**: `get`, `list` permissions on `pods/log` (helpful for automation)
- **Namespace Access**: `get`, `list` permissions on namespaces (for targeting)

**ClusterRoleBinding: `aap-pod-exec-binding`**
- Binds the `aap-pod-exec` ClusterRole to the `default` service account in the `aap` namespace

### 4. Updated AAP Controller Configuration (`roles/configure-aap-controller/tasks/main.yml`)

Added a task to apply the AAP exec RBAC configuration during AAP controller setup.

## Security Benefits

1. **Principle of Least Privilege**: Only grants read permissions needed for Backstage functionality
2. **No Admin Access**: Removes dangerous `cluster-admin` role
3. **Specific Resource Access**: Explicitly defines which resources can be accessed
4. **Read-Only Operations**: Only allows viewing, not modification of cluster resources
5. **Targeted Exec Permissions**: AAP can only exec into pods, not modify them

## How to Apply

The configuration will be automatically applied when running the Backstage configuration playbook:

```bash
ansible-playbook bootstrap-backstage-playbook.yaml
```

## Verification

After applying, you can verify the RBAC configuration:

### Backstage RBAC
```bash
# Check if the ClusterRole exists
oc get clusterrole backstage-read-only

# Check if the ClusterRoleBinding exists
oc get clusterrolebinding backstage-read-only-binding

# Check the service account
oc get serviceaccount default -n backstage

# Test permissions (should succeed for read operations)
oc auth can-i list pods --as=system:serviceaccount:backstage:default
oc auth can-i get deployments --as=system:serviceaccount:backstage:default

# Test permissions (should fail for write operations)
oc auth can-i create pods --as=system:serviceaccount:backstage:default
oc auth can-i delete deployments --as=system:serviceaccount:backstage:default
```

### AAP Pod Exec RBAC
```bash
# Check if the ClusterRole exists
oc get clusterrole aap-pod-exec

# Check if the ClusterRoleBinding exists
oc get clusterrolebinding aap-pod-exec-binding

# Check the service account
oc get serviceaccount default -n aap

# Test permissions (should succeed for exec operations)
oc auth can-i create pods/exec --as=system:serviceaccount:aap:default
oc auth can-i get pods --as=system:serviceaccount:aap:default

# Test actual exec (replace <pod-name> and <namespace> with actual values)
oc exec -it <pod-name> -n <namespace> --as=system:serviceaccount:aap:default -- /bin/bash
```

## Troubleshooting

If Backstage cannot access certain resources, you may need to add additional permissions to the `backstage-read-only` ClusterRole in the `backstage-rbac.yaml` file.

If AAP cannot exec into certain pods, ensure:
1. The target pods exist and are running
2. The pods have the necessary shell/command available (e.g., `/bin/bash`, `/bin/sh`)
3. Network policies don't block the connection

Common additional resources you might need:
- Custom Resource Definitions (CRDs)
- Specific namespaced resources
- Additional API groups

## Token Management

The service account token is generated with a 365-day expiration. To refresh the token:

```bash
oc create token default -n backstage --duration=$((365*24))h
```

Then update the Backstage configuration with the new token.

## Use Cases

### AAP Pod Exec Examples

With the new permissions, AAP can now execute commands in pods across the cluster:

```bash
# Execute a command in a pod
oc exec <pod-name> -n <namespace> -- <command>

# Interactive shell access
oc exec -it <pod-name> -n <namespace> -- /bin/bash

# Run automation scripts
oc exec <pod-name> -n <namespace> -- /path/to/script.sh

# Collect logs or debug information
oc exec <pod-name> -n <namespace> -- cat /var/log/application.log
```

This enables AAP to perform automated operations, debugging, and maintenance tasks across the Kubernetes cluster. 