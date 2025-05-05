# AAP Technical Preview: Self-service Automation Helm Chart

A Helm chart for deploying self-service automation.

## Introduction

This chart deploys the AAP self-service technical preview using the Helm chart packaging format.

This chart is designed for use alongside an Ansible Automation Platform (AAP) instance, so you can authenticate with AAP.

The telemetry data collection feature is enabled by default. For more information, see the [Telemetry capturing](#telemetry-capturing) section. 

## Prerequisites

- Kubernetes 1.25+ (OpenShift 4.12+)
- Helm 3.10+ or [latest release](https://github.com/helm/helm/releases)
- `PersistentVolume` provisioner support in the underlying infrastructure is available.
- [Backstage container image](https://backstage.io/docs/deployment/docker)
- A plugin registry containing the required plugins is deployed in the OpenShift environment (see [this section](#create-plugin-registry) for details)

## Usage

This chart is available in the following formats:

- [OpenShift Helm Catalog](https://docs.redhat.com/en/documentation/openshift_container_platform)
- [Chart Repository](https://helm.sh/docs/topics/chart_repository/)

To fetch the chart from the source repository, run:

```console
git clone https://github.com/ansible-automation-platform/ansible-portal-chart.git
cd ansible-portal-chart
```

### Dependencies

If installing locally, use the following command to add this chart's required dependency:

```console
helm repo add redhat-developer-hub https://charts.openshift.io
helm dependency update
```

### Install and log into OpenShift CLI

To deploy a plugin registry or the helm chart from your local environment, follow the [instructions](https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/cli_tools/openshift-cli-oc#installing-openshift-cli) for installing OpenShift CLI (`oc`) locally, then follow the [instructions](https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/cli_tools/openshift-cli-oc#cli-logging-in_cli-developer-commands) to log in.

Use the following command to create a new OpenShift project:

```console
oc new-project <project-name>
```

Example:
```console
oc new-project my-project
```

Example output:
```
Now using project "my-project" on server "https://openshift.example.com:6443".
```

## Installation

Follow the steps below for the installation procedure, and refer to the other sections of this README as needed before installing. 

**Note:** The install name must be unique for each deployment to avoid conflicts with existing releases. If a release with the same name already exists, the installation will fail.

### Installing from OpenShift Helm Catalog

**Procedure**

1. Ensure you have already completed the ["Create plugin registry"](#create-plugin-registry) step.
2. Click the "Create" button at the top of the modal dialog on the chart page.
3. Create secrets as indicated in the ["Create OpenShift secrets"](#create-openshift-secrets) section.
4. Update values as indicated in the Production ["Update values file"](#update-values-file) section.
5. Click "Create" at the bottom of the page to launch the deployment. 

### Installing from local chart repository

**Procedure**

1. Ensure you have already completed the ["Create plugin registry"](#create-plugin-registry) step. 
2. Create secrets as indicated in the ["Create OpenShift secrets"](#create-openshift-secrets) section.
3. Update your own values file as indicated in the Production ["Update values file"](#update-values-file) section.
4. Use the following command to install the chart:

    ```console
    helm install <install-name> <path-to-chart> -f <your-values-file>
    ```

    Example:
    ```console
    helm install my-installation . -f my-values.yaml
    ```

### Uninstalling the chart

To uninstall/delete the Helm deployment, run:

```console
helm uninstall my-installation
```

This command removes all the Kubernetes components associated with the chart and deletes the release. 

Releases can also be deleted in the OpenShift console, from the Helm -> Helm Releases page. 


## Production environment

In the production environment, plugins are loaded from a plugin registry in your OpenShift project. You must create the plugin registry in the project before using the helm chart.

### Create plugin registry

First, create a local directory to store the plugin .tar files.

```console
mkdir /path/to/<ansible-backstage-plugins-local-dir-changeme>
```

Set an environment variable `DYNAMIC_PLUGIN_ROOT_DIR` to represent the directory path.

```console
export DYNAMIC_PLUGIN_ROOT_DIR=/path/to/<ansible-backstage-plugins-local-dir-changeme>
```

Download the the latest .tar file for the plugins from the [Red Hat Ansible Automation Platform Product Software downloads page](https://access.redhat.com/downloads/content/480/ver=2.5/rhel---9/2.5/x86_64/product-software) to the `DYNAMIC_PLUGIN_ROOT_DIR` path. The format of the filename is ansible-backstage-rhaap-bundle-x.y.z.tar.gz. Substitute the Ansible plugins release version, for example 1.0.0, for x.y.z. Extract the contents inside the directory and run `ls` to ensure the plugin .tar and integrity files are present.

Next, create an httpd service as part of your OpenShift project. Ensure you're using the correct OpenShift project before deploying the service (verify using `oc projects`).

```console
oc new-build httpd --name=plugin-registry --binary
oc start-build plugin-registry --from-dir=$DYNAMIC_PLUGIN_ROOT_DIR --wait
oc new-app --image-stream=plugin-registry
```

### Create OpenShift secrets

Before installing the chart, you must create a set of secrets in your OpenShift project. 

In the OpenShift console, navigate to "Secrets" on the sidebar panel, and click on the blue "Create" dropdown on the page. Select the "Key/value secret" option and add the keys and values as indicated below.

NOTE: The secrets must have the **exact** name and key names shown below to work properly! 

**AAP authentication secrets**

Create a secret named `secrets-rhaap-self-service-preview`. Add the following keys with the appropriate values to the secret:

1. Key: `aap-host-url`

    Value needed: AAP instance URL

2. Key: `oauth-client-id`

   Value needed: AAP OAuth client ID

3. Key: `oauth-client-secret`

   Value needed: AAP OAuth client secret value

4. Key: `aap-token`

   Value needed: Token for AAP user authentication (must have `write` access)

**Github and Gitlab secrets**

Create a secret named `secrets-scm`. Add the following key/value pairs to the secret:

1. Key: `github-token`

   Value needed: Github Personal Access Token (PAT)

2. Key: `gitlab-token`

   Value needed: Gitlab Personal Access Token (PAT)

For details on generating a token and setting up integrations for Github and Gitlab, refer to [GitHub Integration Guide](https://backstage.io/docs/integrations/github/locations#configuration) or [GitLab Integration Guide](https://backstage.io/docs/integrations/gitlab/locations).

### Update values file

**If installing from the OpenShift Helm Catalog:** Update the values shown below in the "Create Helm Release" YAML view. 

**If installing locally from chart source:** Create your own values.yaml file and populate the keys below.

- To get proper connection between frontend and backend of Backstage, update the clusterRouteBase key to match your cluster host URL:

     ```yaml
     # my-values.yaml
       redhat-developer-hub:
         global:
           clusterRouterBase: apps.example.com
     ```

## Telemetry capturing

The telemetry data collection feature helps in collecting and analyzing the telemetry data to improve your experience with self-service technical preview. This feature is enabled by default.

Red Hat collects and analyses the following data:

- Events of page visits and clicks on links or buttons.
- System-related information, for example, locale, timezone, user agent including browser and OS details.
- Page-related information, for example, title, category, extension name, URL, path, referrer, and search parameters.
- Anonymized IP addresses, recorded as 0.0.0.0.
- Anonymized username hashes, which are unique identifiers used solely to identify the number of unique users of the application.

## Chart Values List

| Key | Description | Type | Default |
|-----|-------------|------|---------|
| global.clusterRouterBase | Shorthand for users who do not want to specify a custom HOSTNAME. Used ONLY with the DEFAULT upstream.backstage.appConfig value and with OCP Route enabled. | string | `"apps.example.com"` |
| global.imageTagInfo | The image tag for ansible-backstage-plugins images. | string | `"main"` |
| upstream.backstage.extraEnvVars | List of additional environment variables for the deployment. | list | (See the chart) |
| upstream.backstage.appConfig | Application configuration for the self-service automation installation. | object | `{"ansible":"","auth":"","catalog":""}` |
| upstream.backstage.image | RHDH image registry parameters. | object | `{"registry":"registry.redhat.io","repository":"rhdh/rhdh-hub-rhel9","tag":""1.5.1"}` |
| upstream.backstage.image.registry | Registry to pull the RHDH image from. | string | `registry.redhat.io` |
| upstream.backstage.image.repository | Repository to pull the RHDH image from. | string | `rhdh/rhdh-hub-rhel9` |
| upstream.backstage.image.repository | RHDH image tag. | string | `1.5.1` |
