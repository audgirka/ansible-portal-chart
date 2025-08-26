#!/bin/bash

# Script to create GitHub credentials secret for Helm chart repository access
# This is more secure than embedding credentials in YAML files

# Set your GitHub credentials
GITHUB_USERNAME="your-github-username"
GITHUB_TOKEN="your-github-personal-access-token"

# TODO: Replace the values above with your actual credentials before running this script

# Create the secret in openshift-config namespace
oc create secret generic github-helm-repo-credentials \
  --from-literal=username="${GITHUB_USERNAME}" \
  --from-literal=password="${GITHUB_TOKEN}" \
  --namespace=openshift-config \
  --dry-run=client -o yaml | oc apply -f -

echo "Secret 'github-helm-repo-credentials' created successfully in openshift-config namespace"

# Verify the secret was created
oc get secret github-helm-repo-credentials -n openshift-config
