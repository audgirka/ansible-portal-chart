# Ansible Portal Helm Chart

A Helm chart for deploying Ansible Portal, utilizing Red Hat Developer Hub.

### TL;DR

```
git clone https://github.com/ansible-automation-platform/ansible-portal-chart.git
cd ansible-portal-chart

helm repo add redhat-developer-hub https://charts.openshift.io
helm dependency update

helm install my-rhdh <path-to-chart-directory> -f values-<prod/dev>.yaml
```

## Introduction

This chart depends on the [Red Hat Developer Hub (RHDH) Backstage chart](https://github.com/redhat-developer/rhdh-chart/blob/main/charts/backstage/README.md) to deploy Ansible Portal using the [Helm](https://helm.sh) package manager.

There are two available environments: development and production. You must specify which environment you'd like to use at install time.

This chart is designed for use alongside an Ansible Automation Platform (AAP) instance, so you can authenticate with AAP to RHDH.

## Prerequisites

- Kubernetes 1.25+ (OpenShift 4.12+)
- Helm 3.10+ or [latest release](https://github.com/helm/helm/releases)
- PV provisioner support in the underlying infrastructure
- [Backstage container image](https://backstage.io/docs/deployment/docker)

## Usage

Charts are available in the following formats:

- [Chart Repository](https://helm.sh/docs/topics/chart_repository/)
- [OCI Artifacts](https://helm.sh/docs/topics/registries/)

**Note:** Currently this helm chart has no public releases. To use this chart, you must clone this repository and install the chart from source.

```console
git clone https://github.com/ansible-automation-platform/ansible-portal-chart.git
cd ansible-portal-chart
```

### Dependencies

This chart depends on the productized [RHDH Backstage chart](https://github.com/redhat-developer/rhdh-chart). Use the following command to add the productized chart repository:

```console
helm repo add redhat-developer-hub https://charts.openshift.io
helm dependency update
```

### Install and log into OpenShift CLI

To deploy the helm chart from your local environment, follow the [instructions](https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/cli_tools/openshift-cli-oc#installing-openshift-cli) for installing OpenShift CLI (`oc`) locally, then follow the [instructions](https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/cli_tools/openshift-cli-oc#cli-logging-in_cli-developer-commands) to log in.

Use the following command to create a new OpenShift project:

```console
oc new-project <project-name>
```

Example:
```console
oc new-project my-portal-project
```

Example output:
```
Now using project "my-project" on server "https://openshift.example.com:6443".
```

### Choose environment

Before installing the chart, determine which environment to use. There are two environments: **development** and **production**.

If you are using this chart to test changes to [ansible-backstage-plugins](https://github.com/ansible/ansible-backstage-plugins), you will likely want to use the development values.

If you are using this chart in a production environment, you will need to use the production values.

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

To use the **upstream** plugins, download the plugin .tar and .integrity files from the [ansible-backstage-plugins repo's GitHub release page](https://github.com/ansible/ansible-backstage-plugins/releases) to the `DYNAMIC_PLUGIN_ROOT_DIR` path.

To use the **downstream** plugins, download the the latest .tar file for the plugins from the [Red Hat Ansible Automation Platform Product Software downloads page](https://access.redhat.com/downloads/content/480/ver=2.5/rhel---9/2.5/x86_64/product-software) to the `DYNAMIC_PLUGIN_ROOT_DIR` path. The format of the filename is ansible-backstage-rhaap-bundle-x.y.z.tar.gz. Substitute the Ansible plugins release version, for example 1.0.0, for x.y.z. Extract the contents inside the directory and run `ls` to ensure the plugin .tar and integrity files are present.

(**Note:** To use locally built plugins in the plugin registry, you will need to update the integrity keys in the values-prod.yaml file to the values in your local plugins' .integrity files. This is not recommended, as the integrity values update every time the plugins are rebuilt. Instead, we recommend following the development section below.)

Next, create an httpd service as part of your OpenShift project. Ensure you're using the correct OpenShift project before deploying the service (verify using `oc projects`).

```console
oc new-build httpd --name=plugin-registry --binary
oc start-build plugin-registry --from-dir=$DYNAMIC_PLUGIN_ROOT_DIR --wait
oc new-app --image-stream=plugin-registry
```

### Update values.yaml

To make this chart work properly, update the placeholder values in values.yaml.

- To get proper connection between frontend and backend of Backstage, update the clusterRouteBase key to match your cluster host URL:

     ```yaml
     # values.yaml
     global:
       clusterRouterBase: apps.example.com
     ```

- Under the `appConfig.ansible` section, update the `rhaap`, `baseUrl` and `token` values from "changeme" to the IP address or URL of your AAP instance, and an authentication token from the AAP instance.

     ```yaml
     # values.yaml
       appConfig:
          enableExperimentalRedirectFlow: true
          ansible:
            rhaap:
              baseUrl: "changeme"  # in the form https://<ip-or-url-to-AAP-instance>
              token: "changeme"
     ```
-  Under the `appConfig.auth.providers.rhaap.production` section,update the `host`, `clientId`, and `clientSecret` values from "changeme" to the IP address or URL of your AAP instance, AAP OAuth application clientId, and AAP OAuth clientSecret respectively.

     ```yaml
     # values.yaml
       appConfig:
          auth:
            providers:
              rhaap:
                production:
                  host: "changeme"
                  clientId: "changeme"
                  clientSecret: "changeme"
     ```

-  Under the `appConfig.integrations` section, update the github and gitlab `token` values from "changeme" to your respective Personal Access Token (PAT) for GitHub or GitLab. For details on generating a token and setting up integrations, refer to [GitHub Integration Guide](https://backstage.io/docs/integrations/github/locations#configuration) or [GitLab Integration Guide](https://backstage.io/docs/integrations/gitlab/locations).

     ```yaml
     # values.yaml
        integrations:
          github:
            - host: github.com
              token: "changeme"
          gitlab:
            - host: gitlab.com
              token: "changeme"
     ```

### Install the chart

The following command can be used to install the chart:

```console
helm install <install-name> <path-to-chart> -f values-prod.yaml
```

Example:
```console
helm install my-portal <path-to-chart> -f values-prod.yaml
```

**Note:** The install name must be unique for each deployment to avoid conflicts with existing releases. If a release with the same name already exists, the installation will fail.

## Development Environment

In the development environment, plugin images are pulled from a private Quay repository. This repository stores images built from pull request changes on the [ansible-backstage-plugins repository](https://github.com/ansible/ansible-backstage-plugins/tree/main).

**Note:** If you would like to test local changes to plugins, open a PR to ansible-backstage-plugins first, then set the `global.imageTagInfo` value to the new Quay image tag built from the PR . See the **"Update values.yaml"** section below for details. 

### Create secret to access private Quay repository

Ensure your podman/docker credentials are stored in an auth.json file. Next, use the below command to add a secret to your OpenShift environment using the auth file.

```console
oc create secret generic <install-name>-dynamic-plugins-registry-auth --from-file=<path-to-auth.json>
```

Example:
```console
oc create secret generic my-portal-dynamic-plugins-registry-auth --from-file=<path-to-auth.json>
```

**Note:** The secret must have this exact name pattern in order to work correctly.

### Update values.yaml

To make this chart work properly, update the placeholder values in values.yaml.

- To get proper connection between frontend and backend of Backstage, update the clusterRouteBase key value to your cluster host URL:

     ```yaml
     # values.yaml
     global:
       clusterRouterBase: apps.example.com
     ```

- Under the `appConfig.ansible` section, update the `rhaap`, `baseUrl` and `token` values from "changeme" to the IP address or URL of your AAP instance, and an authentication token from the AAP instance. 

     ```yaml
     # values.yaml
       appConfig:
          enableExperimentalRedirectFlow: true
          ansible:
            rhaap:
              baseUrl: "changeme"  # in the form https://<ip-or-url-to-AAP-instance>
              token: "changeme"
     ```

-  Under the `appConfig.auth.providers.rhaap.production` section, update the `host`, `clientId`, and `clientSecret` values from "changeme" to the IP address or URL of your AAP instance, AAP OAuth application clientId, and AAP OAuth clientSecret respectively.

     ```yaml
     # values.yaml
       appConfig:
          auth:
            providers:
              rhaap:
                production:
                  host: "changeme"
                  clientId: "changeme"
                  clientSecret: "changeme"
     ```

-  Under the `appConfig.integrations` section, update the github and gitlab `token` values from "changeme" to your respective Personal Access Token (PAT) for GitHub or GitLab. For details on generating a token and setting up integrations, refer to [GitHub Integration Guide](https://backstage.io/docs/integrations/github/locations#configuration) or [GitLab Integration Guide](https://backstage.io/docs/integrations/gitlab/locations).

     ```yaml
     # values.yaml
        integrations:
          github:
            - host: github.com
              token: "changeme"
          gitlab:
            - host: gitlab.com
              token: "changeme"
     ```

- Under global.imageTagInfo, you can either update the Quay image tag inside the values-dev.yaml file manually, or pass the value via the command line using `--set global.imageTagInfo=<image-tag>`.

     ```yaml
     # values-dev.yaml
      global:
        imageTagInfo: # Required: Update here or pass using --set
     ```

- **Optional**: If you are using a development environment where you need to disable SSL checks, under the `appConfig.ansible` section, update the `checkSSL` value from `true` to `false`. Also, under `extraEnvVars` you can add the environment variable `NODE_TLS_REJECT_UNAUTHORIZED` with `value: '0'`. 

     ```yaml
     # values.yaml
       appConfig:
          enableExperimentalRedirectFlow: true
          ansible:
            rhaap:
              checkSSL: true
     ```

     ```yaml
     # values.yaml
       extraEnvVars:
            - name: NODE_TLS_REJECT_UNAUTHORIZED
              value: '0'
     ```


### Install the chart

The following command can be used to install the chart:

```console
helm install <install-name> <path-to-chart> -f values-dev.yaml
```

Example:
```console
helm install my-portal <path-to-chart> -f values-dev.yaml
```

**Note:** The install name must be unique for each deployment to avoid conflicts with existing releases. If a release with the same name already exists, the installation will fail.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
| global.clusterRouterBase | Shorthand for users who do not want to specify a custom HOSTNAME. Used ONLY with the DEFAULT upstream.backstage.appConfig value and with OCP Route enabled. | string | `"apps.example.com"` |
| global.imageTagInfo | *Development environment* - Used to specify a Quay image tag for ansible-backstage-plugins images. | string | `""` |
| upstream.backstage.extraEnvVars | Overrides the default authentication plugin to use the Ansible dynamic auth plugin. Must be set to 'true' for the custom AAP sign in page to work. | string | `"true"` |
| upstream.backstage.appConfig | Application configuration for the RHDH and Ansible Portal installation. | object | `{"ansible":"","auth":"","catalog":""}` |
| upstream.backstage.appConfig.ansible.rhaap.baseUrl | IP address or URL to your AAP instance. | string | `"changeme"` |
| upstream.backstage.appConfig.ansible.rhaap.baseUrl | User authentication token from the AAP instance. | string | `"changeme"` |
| upstream.backstage.appConfig.auth.providers.rhaap.production.host | IP address or URL to your AAP instance. | string | `"changeme"` |
| upstream.backstage.appConfig.auth.providers.rhaap.production.host | AAP instance OAuth client ID.| string | `"changeme"` |
| upstream.backstage.appConfig.auth.providers.rhaap.production.host | AAP instance OAuth client secret. | string | `"changeme"` |
| upstream.backstage.image | RHDH image registry parameters. | object | `{"registry":"quay.io","repository":"rhdh/rhdh-hub-rhel9","tag":""1.5"}` |
| upstream.backstage.image.registry | Registry to pull the RHDH image from. | string | `quay.io` |
| upstream.backstage.image.repository | Repository to pull the RHDH image from. | string | `rhdh/rhdh-hub-rhel9` |
| upstream.backstage.image.repository | RHDH image tag. | string | `1.5` |
