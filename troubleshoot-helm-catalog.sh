#!/bin/bash

echo "🔍 Troubleshooting Helm Chart in OpenShift Developer Catalog"
echo "=========================================================="

# Check if HelmChartRepository exists
echo "1. Checking HelmChartRepository status..."
oc get helmchartrepository -n openshift-config

echo -e "\n2. Checking HelmChartRepository details..."
oc describe helmchartrepository ansible-portal-private-repo -n openshift-config

# Check if secret exists
echo -e "\n3. Checking GitHub credentials secret..."
oc get secret github-helm-repo-credentials -n openshift-config

# Check secret contents (without exposing values)
echo -e "\n4. Checking secret keys..."
oc get secret github-helm-repo-credentials -n openshift-config -o jsonpath='{.data}' | jq 'keys'

# Test URL accessibility
echo -e "\n5. Testing Helm repository URL..."
REPO_URL="https://ansible-automation-platform.github.io/ansible-portal-chart/"
echo "Testing: $REPO_URL"

# Check if index.yaml exists
curl -s -I "${REPO_URL}index.yaml" | head -n 1

# Try to fetch index.yaml content
echo -e "\n6. Checking index.yaml content..."
curl -s "${REPO_URL}index.yaml" | head -20

# Check OpenShift Helm operator
echo -e "\n7. Checking OpenShift Helm operator..."
oc get pods -n openshift-helm-operator

# Check for any error events
echo -e "\n8. Checking recent events..."
oc get events -n openshift-config --sort-by='.lastTimestamp' | grep -i helm | tail -10

echo -e "\n9. Checking cluster operator status..."
oc get clusteroperator console

echo -e "\n✅ Troubleshooting complete!"
echo "If issues persist, check the solutions in the troubleshooting guide."
