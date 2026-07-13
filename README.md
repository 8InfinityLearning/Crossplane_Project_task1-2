# Crossplane Manual XR Test Validation

## TASK 01 : Crossplane XR manual validatoin

## Repository Structure is maintained as mentioned below

* **`xrd.yaml`**: The `CompositeResourceDefinition` defining the custom API (`XConfigMapV3`) schema, parameters, and structural validation.
* **`composition.yaml`**: The blueprint that implements `XConfigMapV3` using modern Composition Pipelines and handles field transformations.
* **`claim.yaml`**: A sample user instance (Claim) requesting a specific configuration (`my-first-configmap`).
* **`function-patch-and-transform.yaml`**: Installs the required Crossplane function to execute patch-and-transform operations.
* **`provider.yaml` & `providerconfig.yaml`**: The definition and credential configuration for the Upbound Kubernetes provider.
* **`live-schema.yaml`**: The automatically generated, live CustomResourceDefinition (CRD) observed inside the cluster.

## Please follow the below mentioned Deployment Order

To deploy this architecture to a running Crossplane control plane, please execute the commands in the following sequence:

# 1. Install the Kubernetes Provider and the P&T Function
kubectl apply -f provider.yaml
kubectl apply -f function-patch-and-transform.yaml

# 2. Configure authentication details for the Provider
kubectl apply -f providerconfig.yaml

# 3. Define the custom API structure
kubectl apply -f xrd.yaml

# 4. Supply the composition implementation logic
kubectl apply -f composition.yaml

# 5. Create a resource instance via the Claim
kubectl apply -f claim.yaml


# TASK 2 : Crossplane XR Lifecycle Automated Validation Script

The below is for`validate-xr-lifecycle-task2.ps1` file. An automation script designed to orchestrate, time, and evaluate the runtime reconciliation cycle of Crossplane Composite Resources (XR).

## Overview

The script automates testing by replacing manual status polling. It performs the following sequential duties:
1. **Manifest Application**: Applies the target `claim.yaml` configuration to the cluster.
2. **Reconciliation Tracking**: Enters an active polling loop querying the custom API resource `xconfigmapv3s.demo.crossplane.io`.
3. **Condition Parsing**: Extracts and deserializes raw JSON status payloads to evaluate `Synced` and `Ready` conditions directly.
4. **Report Compiling**: Persists structured metrics detailing performance and final validation states to disk.


## ## Please follow the below mentioned for running the Script

### Prerequisites
* PowerShell
* `kubectl` authenticated against an active Kubernetes cluster containing your Crossplane control plane.

### Execution Command
Execute the script from a terminal window within its host folder:
```powershell
.\validate-xr-lifecycle-task2.ps1
