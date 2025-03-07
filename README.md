# Vault Secrets Operator Demo
This guide will walk you through the process of setting up and using the Vault Secrets Operator to manage your Vault secrets in a Kubernetes environment. By following the steps outlined below, you'll be able to securely store and retrieve secrets using HashiCorp Vault and Kubernetes.

# Requirements
Everything in this demo is done locally, so there are a few requirements you need to have installed on your machine:

- Terraform
- Docker
- Kind
- Kubectl
- Helm

# Usage

```shell
cd tf/
terraform init
terraform apply -auto-approve
```

```shell
kubectl get namespaces

kubectl get pods -n vault
kubectl get pods -n vault-secrets-operator

kubectl get secrets -n example
kubectl get pods -n example

watch kubectl get pods -n example
watch kubectl logs -l=app=example -n=example --prefix=true --tail=50

# change secrets in Vault UI
```

```shell
terraform destroy -auto-approve
```
