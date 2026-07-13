# Crossplane Manual XR Test Validation

This project contains a complete Crossplane configuration demonstrating how to use the **Pipeline Mode** along with the `function-patch-and-transform` engine to dynamically provision and manage standard Kubernetes `ConfigMap` resources using a Composite Resource Definition (XRD) and a Claim.

## Repository Structure is maintained as mentioned below

* **`xrd.yaml`**: The `CompositeResourceDefinition` defining the custom API (`XConfigMapV3`) schema, parameters, and structural validation.
* **`composition.yaml`**: The blueprint that implements `XConfigMapV3` using modern Composition Pipelines and handles field transformations.
* **`claim.yaml`**: A sample user instance (Claim) requesting a specific configuration (`my-first-configmap`).
* **`function-patch-and-transform.yaml`**: Installs the required Crossplane function to execute patch-and-transform operations.
* **`provider.yaml` & `providerconfig.yaml`**: The definition and credential configuration for the Upbound Kubernetes provider.
* **`live-schema.yaml`**: The automatically generated, live CustomResourceDefinition (CRD) observed inside the cluster.

## Please follow the below mentioned Deployment Order

To deploy this architecture to a running Crossplane control plane, please execute the commands in the following sequence:

```bash
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