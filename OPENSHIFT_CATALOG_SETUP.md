# Adding Ansible Portal Chart to OpenShift Developer Catalog

This guide explains how to add your private Helm chart repository to OpenShift's Developer Catalog.

## Prerequisites

1. **OpenShift cluster admin access** - You need cluster-admin privileges to create HelmChartRepository resources
2. **GitHub Personal Access Token** - For accessing private repository
3. **Properly configured gh-pages branch** - With Helm repository structure

## Step 1: Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate a new token with these scopes:
   - `repo` (Full control of private repositories)
   - `read:org` (if the repository is in an organization)
3. Copy the token (starts with `ghp_`)

## Step 2: Set up GitHub Pages Helm Repository

### Option A: Manual Setup
1. Ensure your `gh-pages` branch exists
2. Create an `index.yaml` file in the root of gh-pages branch:
   ```yaml
   apiVersion: v1
   entries: {}
   generated: "2024-01-01T00:00:00Z"
   ```

### Option B: Automated Setup (Recommended)
1. Copy the `.github/workflows/helm-release.yml` file to your repository
2. Push to main branch - this will automatically:
   - Package your Helm chart
   - Update the repository index
   - Deploy to gh-pages branch

## Step 3: Add Repository to OpenShift

### For Public Access (if you make the repo public later):
```bash
oc apply -f helm-chart-repository.yaml
```

### For Private Repository Access:

1. **Create the credentials secret (Option A - Command line):**
   ```bash
   oc create secret generic github-helm-repo-credentials \
     --from-literal=username=your-github-username \
     --from-literal=password=ghp_your_personal_access_token \
     -n openshift-config
   ```

   **Or use the provided script (Option B - Script):**
   ```bash
   # Edit create-github-secret.sh with your credentials first
   ./create-github-secret.sh
   ```

2. **Apply the HelmChartRepository:**
   ```bash
   # Apply the HelmChartRepository configuration
   oc apply -f helm-chart-repository-with-secret.yaml
   ```

## Step 4: Verify Installation

1. **Check the repository status:**
   ```bash
   oc get helmchartrepository -n openshift-config
   ```

2. **View in OpenShift Console:**
   - Navigate to Developer → Add → Helm Chart
   - You should see "Ansible Portal Chart Repository" in the repository dropdown
   - Your chart should appear in the catalog

## Step 5: Install Chart from Catalog

1. In OpenShift Console, go to Developer → Add → Helm Chart
2. Select your repository from the dropdown
3. Find "Automation Portal" chart
4. Click "Install Helm Chart"
5. Configure the values (especially `clusterRouterBase`)
6. Click "Install"

## Troubleshooting

### Repository Not Appearing
- Check HelmChartRepository status: `oc describe helmchartrepository ansible-portal-chart-repo -n openshift-config`
- Verify GitHub token has correct permissions
- Ensure gh-pages branch is accessible at the URL

### Authentication Issues
- Verify the secret contains correct GitHub credentials
- Check that the personal access token hasn't expired
- Ensure the token has `repo` scope for private repositories

### Chart Not Loading
- Verify `index.yaml` exists in gh-pages branch
- Check that the chart is properly packaged
- Ensure the URL in HelmChartRepository matches your gh-pages URL

## Security Considerations

1. **Use GitHub App instead of Personal Access Token** for production environments
2. **Rotate tokens regularly** - GitHub tokens should be rotated periodically
3. **Limit token scope** - Only grant minimum required permissions
4. **Monitor access logs** - Keep track of who accesses your private repository

## Files Overview

After setup, you'll have these key files:

- **`helm-chart-repository.yaml`** - For public repository access
- **`helm-chart-repository-with-secret.yaml`** - For private repository access (recommended)
- **`create-github-secret.sh`** - Script to create GitHub credentials secret
- **`.github/workflows/helm-release.yml`** - Automated Helm repository management
- **`OPENSHIFT_CATALOG_SETUP.md`** - This setup guide

## Repository URL Structure

Your Helm repository will be accessible at:
```
https://ansible-automation-platform.github.io/ansible-portal-chart/
```

The repository structure should look like:
```
gh-pages branch:
├── index.yaml                           # Helm repository index
├── redhat-rhaap-portal-2.0.0-pre-release.tgz  # Packaged chart
└── ...                                  # Other chart versions
```
