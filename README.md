# AAP Technical Preview: Self-service Automation Helm Chart

A Helm chart for deploying self-service automation.

## Introduction

This chart deploys the AAP self-service technical preview using the Helm chart packaging format. This chart is designed for use alongside an Ansible Automation Platform (AAP) instance, so you can authenticate with AAP.

The telemetry data collection feature is enabled by default. For more information, see the [Telemetry capturing](#telemetry-capturing) section. 

## Usage

This chart is available in the following formats:

- [OpenShift Helm Catalog](https://docs.redhat.com/en/documentation/openshift_container_platform)
- [Chart Repository](https://helm.sh/docs/topics/chart_repository/)

## Installing from OpenShift Helm Catalog

**Note:** The install name must be unique for each deployment to avoid conflicts with existing releases. If a release with the same name already exists, the installation will fail.

### Prerequisites

The following prerequisites are needed before installation:

- Kubernetes 1.25+ (OpenShift 4.12+)
- Helm 3.10+ or [latest release](https://github.com/helm/helm/releases)
- `PersistentVolume` provisioner support in the underlying infrastructure is available
- [Backstage container image](https://backstage.io/docs/deployment/docker)
- A plugin registry containing the required plugins deployed in the OpenShift environment (see the [Create plugin registry](#create-plugin-registry) section below for details)
- Secrets containing AAP authentication values and SCM tokens created as shown in the [Create OpenShift secrets](#create-openshift-secrets) section below.

### Procedure

1. Ensure you have completed all prerequistes listed above. 
2. Click the "Create" button at the top of the modal dialog on the chart page.
3. Update the values shown below in the "Create Helm Release" YAML view. 
    - To get proper connection between frontend and backend of Backstage, update the `clusterRouterBase` key to match your cluster host URL:

        ```yaml
        redhat-developer-hub:
        global:
            clusterRouterBase: apps.example.com
        ```

4. Click "Create" at the bottom of the page to launch the deployment. 

## Create plugin registry

### Log into OpenShift CLI

To deploy a plugin registry or to manually install the Helm chart, follow the [instructions](https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/cli_tools/openshift-cli-oc#installing-openshift-cli) for installing OpenShift CLI (`oc`) locally, then follow the [instructions](https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/cli_tools/openshift-cli-oc#cli-logging-in_cli-developer-commands) to log in.

Use the following command to create a new OpenShift project:
```console
oc new-project <project-name>
```

Or, switch to an existing project with the following command:
```console
oc project <project-name>
```

### Download plugins and push to the registry

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

## Create OpenShift secrets

Before installing the chart, you must create a set of secrets in your OpenShift project. 

In the OpenShift console, ensure your project is selected. Navigate to "Secrets" on the sidebar panel, and click on the blue "Create" dropdown on the page. Select the "Key/value secret" option and add the keys and values as indicated below.

NOTE: The secrets must have the **exact** name and key names shown below to work properly! 

### AAP authentication secrets

Create a secret named `secrets-rhaap-self-service-preview`. Add the following keys with the appropriate values to the secret:

1. Key: `aap-host-url`

    Value needed: AAP instance URL

2. Key: `oauth-client-id`

   Value needed: AAP OAuth client ID

3. Key: `oauth-client-secret`

   Value needed: AAP OAuth client secret value

4. Key: `aap-token`

   Value needed: Token for AAP user authentication (must have `write` access)

### Github and Gitlab secrets

Create a secret named `secrets-scm`. Add the following key/value pairs to the secret:

1. Key: `github-token`

   Value needed: Github Personal Access Token (PAT)

2. Key: `gitlab-token`

   Value needed: Gitlab Personal Access Token (PAT)

For details on generating a token and setting up integrations for Github and Gitlab, refer to [GitHub Integration Guide](https://backstage.io/docs/integrations/github/locations#configuration) or [GitLab Integration Guide](https://backstage.io/docs/integrations/gitlab/locations).

## Manual Installation from the chart repository

### Prerequisites

- See the [Installation prerequisites](#installation-prerequisites) section above
- Log into OpenShift CLI and create a new project (see the [Log into OpenShift CLI](#log-into-openshift-cli) section)

**Procedure**

1. Ensure you have completed all prerequisites.
2. Create your own values.yaml file and populate the keys below.

    - To get proper connection between frontend and backend of Backstage, update the clusterRouterBase key to match your cluster host URL:

        ```yaml
        redhat-developer-hub:
        global:
            clusterRouterBase: apps.example.com
        ```
3. Add the chart repository using the following command:

    ```console
    helm repo add openshift-helm-charts https://charts.openshift.io/
    ```

4. Install the chart:

    ```console
    helm install <release-name> openshift-helm-charts/redhat-rhaap-self-service-preview -f <your-values-file>
    ```

    Example:
    ```console
    helm install my-release openshift-helm-charts/redhat-rhaap-self-service-preview -f my-values.yaml
    ```

## Uninstalling the chart

To uninstall/delete the Helm deployment, run:

```console
helm uninstall <release-name>
```

Example:
```console
helm uninstall my-release
```

This command removes all the Kubernetes components associated with the chart and deletes the release. 

Releases can also be deleted in the OpenShift console, from the Helm -> Helm Releases page. 

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
