# Troubleshooting Helm Chart in OpenShift Developer Catalog

## Common Issues and Solutions

### 1. Chart Not Appearing in Developer Catalog

#### **Issue**: Helm chart doesn't show up in OpenShift Developer Catalog

#### **Possible Causes & Solutions**:

**A. HelmChartRepository not created or misconfigured**
```bash
# Check if HelmChartRepository exists
oc get helmchartrepository -n openshift-config

# If missing, apply the configuration
oc apply -f helm-chart-repository-with-secret.yaml
```

**B. GitHub credentials secret missing or incorrect**
```bash
# Check if secret exists
oc get secret github-helm-repo-credentials -n openshift-config

# If missing, create it
./create-github-secret.sh

# Verify secret has correct keys
oc get secret github-helm-repo-credentials -n openshift-config -o yaml
```

**C. GitHub Pages not properly configured**
```bash
# Test if the Helm repository URL is accessible
curl -I https://ansible-automation-platform.github.io/ansible-portal-chart/index.yaml

# Should return: HTTP/2 200
```

**D. Helm repository index.yaml missing or malformed**
```bash
# Check index.yaml content
curl -s https://ansible-automation-platform.github.io/ansible-portal-chart/index.yaml

# Should contain valid YAML with entries
```

### 2. GitHub Pages Setup Issues

#### **Issue**: GitHub Pages URL returns 404 or authentication errors

#### **Solutions**:

**A. Enable GitHub Pages in repository settings**
1. Go to repository Settings → Pages
2. Set Source to "Deploy from a branch"
3. Select `gh-pages` branch and `/ (root)` folder
4. Save settings

**B. Run GitHub Actions workflow**
```bash
# Push to main branch to trigger workflow
git add .
git commit -m "Update Helm chart"
git push origin main
```

**C. Check GitHub Actions workflow status**
- Go to Actions tab in GitHub repository
- Verify "Release Helm Chart" workflow completed successfully
- Check for any error messages

### 3. Authentication Issues

#### **Issue**: Private repository access denied

#### **Solutions**:

**A. Verify GitHub Personal Access Token**
- Token must have `repo` scope for private repositories
- Token must not be expired
- Test token manually:
```bash
curl -H "Authorization: token YOUR_TOKEN" \
  https://api.github.com/repos/ansible-automation-platform/ansible-portal-chart
```

**B. Update secret with correct credentials**
```bash
# Delete old secret
oc delete secret github-helm-repo-credentials -n openshift-config

# Create new secret with correct token
./create-github-secret.sh
```

### 4. OpenShift Configuration Issues

#### **Issue**: HelmChartRepository exists but chart still not visible

#### **Solutions**:

**A. Check HelmChartRepository status**
```bash
oc describe helmchartrepository ansible-portal-private-repo -n openshift-config
```

Look for error messages in the status section.

**B. Restart OpenShift console pods**
```bash
# Get console pods
oc get pods -n openshift-console

# Delete console pods to force restart
oc delete pods -l app=console -n openshift-console
```

**C. Check cluster operator status**
```bash
oc get clusteroperator console
# Should show Available=True, Progressing=False, Degraded=False
```

### 5. Chart Metadata Issues

#### **Issue**: Chart appears but with incorrect information

#### **Solutions**:

**A. Verify Chart.yaml annotations**
```yaml
annotations:
  charts.openshift.io/archs: x86_64
  charts.openshift.io/name: "Automation Portal"
  charts.openshift.io/provider: Red Hat
  charts.openshift.io/supportURL: https://access.redhat.com/support
```

**B. Check chart keywords and description**
```yaml
keywords:
- aap
- rhaap
- portal
- automation
- ansible
- redhat
```

### 6. Network and Connectivity Issues

#### **Issue**: OpenShift cannot reach GitHub Pages

#### **Solutions**:

**A. Test connectivity from OpenShift cluster**
```bash
# Create a test pod
oc run test-connectivity --image=curlimages/curl --rm -it --restart=Never -- \
  curl -I https://ansible-automation-platform.github.io/ansible-portal-chart/index.yaml
```

**B. Check firewall/proxy settings**
- Ensure OpenShift cluster can reach `*.github.io` domains
- Check corporate firewall rules
- Verify proxy configuration if applicable

## Quick Diagnostic Script

Run the troubleshooting script to get a comprehensive status check:

```bash
./troubleshoot-helm-catalog.sh
```

## Step-by-Step Verification

### 1. Verify GitHub Pages Setup
```bash
# Should return HTTP 200
curl -I https://ansible-automation-platform.github.io/ansible-portal-chart/index.yaml

# Should show valid Helm repository index
curl -s https://ansible-automation-platform.github.io/ansible-portal-chart/index.yaml | head -20
```

### 2. Verify OpenShift Configuration
```bash
# Check HelmChartRepository
oc get helmchartrepository -n openshift-config

# Check secret
oc get secret github-helm-repo-credentials -n openshift-config

# Check for errors
oc describe helmchartrepository ansible-portal-private-repo -n openshift-config
```

### 3. Verify in OpenShift Console
1. Navigate to Developer → Add → Helm Chart
2. Check repository dropdown for "Ansible Portal Chart Repository (Private)"
3. Look for "Automation Portal" chart in the catalog

## Common Error Messages

### "Repository not found"
- Check GitHub repository URL
- Verify repository is accessible
- Check GitHub token permissions

### "Authentication failed"
- Verify GitHub token is correct and not expired
- Check secret exists in correct namespace
- Ensure token has `repo` scope

### "Invalid index.yaml"
- Run GitHub Actions workflow to regenerate index
- Check index.yaml syntax
- Verify chart packaging

### "Chart not compatible"
- Check Kubernetes version compatibility
- Verify chart API version
- Check required OpenShift version

## Getting Help

If issues persist:

1. Check OpenShift documentation for HelmChartRepository
2. Verify GitHub Pages is properly configured
3. Test with a public repository first
4. Check OpenShift cluster logs for detailed error messages

## Useful Commands Reference

```bash
# List all Helm repositories
oc get helmchartrepository -A

# Check specific repository status
oc describe helmchartrepository <name> -n openshift-config

# View repository events
oc get events -n openshift-config | grep helm

# Test Helm repository manually
helm repo add test-repo https://ansible-automation-platform.github.io/ansible-portal-chart/
helm repo update
helm search repo test-repo
```
