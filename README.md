# AAP Technical Preview: Self-service Automation Helm Chart

A Helm chart for deploying self-service automation, utilizing Red Hat Developer Hub.

## Introduction

This chart deploys the AAP self-service technical preview using the Helm chart packaging format.

This chart is designed for use alongside an Ansible Automation Platform (AAP) instance, so you can authenticate with AAP.

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

This chart depends on the productized [RHDH chart](https://github.com/redhat-developer/rhdh-chart). If installing manually, use the following command to add the needed repository:

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

## Choose environment

Before installing the chart, determine which environment to use. There are two environments: **development** and **production**. This chart defaults to using the production environment and should only be switched to development if you are testing changes to the Ansible plugins or this chart. 

The production environment requires a plugin-registry set up in your OpenShift project.

The development environment pulls plugin images from the [ansible-backstage-plugins Quay repository](https://quay.io/repository/ansible/ansible-backstage-plugins). The `main` tag is pulled by default. See the ["Development Environment"](#development-environment) section for configuration instructions. 


## Installation

Follow the steps below for the installation procedure, and refer to the other sections of this README as needed before installing. 

**Note:** The install name must be unique for each deployment to avoid conflicts with existing releases. If a release with the same name already exists, the installation will fail.

### Installing from OpenShift Helm Catalog

**Procedure**

1. Ensure you have already completed the ["Create plugin registry"](#create-plugin-registry) step.
2. Click the "Create" button at the top of the modal dialog on the chart page.
3. Create secrets as indicated in the ['Create OpenShift secrets](#create-openshift-secrets) section.
4. Update values as indicated in the Production ["Update values file" ](#update-values-file) section.
5. Click "Create" at the bottom of the page to launch the deployment. 

### Installing from local chart repository

**Procedure**

1. Ensure you have already completed the ["Create plugin registry"](#create-plugin-registry) step, or switched to the development environment. 
2. Create secrets as indicated in the ['Create OpenShift secrets](#create-openshift-secrets) section.
3. Update your own values file as indicated in the Production ["Update values file" section](#update-values-file) or Development ["Update values file" section](#update-values-files) sections. 
4. Use the following command to install the chart:

    ```console
    helm install <install-name> <path-to-chart> -f <your-values-file>
    ```

    Example:
    ```console
    helm install my-installation . -f my-values.yaml
    ```


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

   Value needed: Token for AAP user authentication

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
           clusterRouterBase: apps.your.cluster.url.com
     ```

## Development Environment

In the development environment, plugin images are pulled from a private Quay repository. This repository stores images built from pull request changes on the [ansible-backstage-plugins repository](https://github.com/ansible/ansible-backstage-plugins/tree/main).

### Create secret to access private Quay repository

Ensure your podman/docker credentials are stored in an auth.json file. Next, use the below command to add a secret to your OpenShift environment using the auth file.

```console
oc create secret generic <install-name>-dynamic-plugins-registry-auth --from-file=<path-to-auth.json>
```

Example:
```console
oc create secret generic my-installation-dynamic-plugins-registry-auth --from-file=<path-to-auth.json>
```

**Note:** The secret must have this exact name pattern in order to work correctly.

### Update values files

**If installing from the OpenShift Helm Catalog:** Update the values shown below in the "Create Helm Release" YAML view. 

**If installing locally from chart source:** Create your own values.yaml file and populate the keys below. 

- Update the `global._environment._production` key to `false`, and the `global._environment._development` key to `true`.
 
     ```yaml
     # my-values.yaml
       redhat-developer-hub:
         global:
           _environment:
             _production: false
             _development: true
     ```

- To get proper connection between frontend and backend of Backstage, update the clusterRouteBase key value to your cluster host URL:

     ```yaml
     # my-values.yaml
       redhat-developer-hub:
         global:
           clusterRouterBase: apps.your.cluster.url.com
     ```

- Under global.imageTagInfo, you can either update the Quay image tag inside your values file, or pass the value via the command line using `--set global.imageTagInfo=<image-tag>`. This tag defaults to `main`. 

     ```yaml
     # my-values.yaml
       redhat-developer-hub:
         global:
           imageTagInfo: pr-number # Required: Update here or pass using --set
     ```

- **Optional**: If you are using a development environment where you need to disable SSL checks, under the `appConfig.ansible.rhaap` section, update the `checkSSL` value from `true` to `false`. Also, update the `appConfig.auth.providers.rhaap.production` `checkSSL` value from `true` to `false`. 

    Under extraEnvVars in values.yaml, add the environment variable `NODE_TLS_REJECT_UNAUTHORIZED` with `value: '0'`. Make sure to add this in the `values.yaml` file, not your custom values file, as adding an entry into the extraEnvVars will override env vars in other value files. This is a known issue, with updates tracked [here](https://issues.redhat.com/browse/RHIDP-6082). 

    To allow users to sign in even if they are not present in the catalog, add `appConfig.dangerouslyAllowSignInWithoutUserInCatalog` and set its value to `true`.

     ```yaml
     # my-values.yaml
       redhat-developer-hub:
         upstream:
           backstage:
             appConfig:
               ansible:
                 rhaap:
                   checkSSL: false
     ```

     ```yaml
     # my-values.yaml
       redhat-developer-hub:
         upstream:
           backstage:
             appConfig:
               auth:
                 providers:
                   rhaap:
                     production:
                       checkSSL: false
     ```

     ```yaml
     # values.yaml
       redhat-developer-hub:
         upstream:
           backstage:
             extraEnvVars:
               - name: NODE_TLS_REJECT_UNAUTHORIZED
                 value: '0'
     ```

     ```yaml
     # my-values.yaml
       redhat-developer-hub:
         upstream:
           backstage:
             appConfig:
               dangerouslyAllowSignInWithoutUserInCatalog: true
     ```

## Chart Values List

| Key | Description | Type | Default |
|-----|-------------|------|---------|
| global.clusterRouterBase | Shorthand for users who do not want to specify a custom HOSTNAME. Used ONLY with the DEFAULT upstream.backstage.appConfig value and with OCP Route enabled. | string | `"apps.example.com"` |
| global.imageTagInfo | *Development environment* - Used to specify a Quay image tag for ansible-backstage-plugins images. | string | `"main"` |
| upstream.backstage.extraEnvVars | List of additional environment variables for the deployment. | list | (See the chart) |
| upstream.backstage.appConfig | Application configuration for the self-service automation installation. | object | `{"ansible":"","auth":"","catalog":""}` |
| upstream.backstage.image | RHDH image registry parameters. | object | `{"registry":"quay.io","repository":"rhdh/rhdh-hub-rhel9","tag":""1.5"}` |
| upstream.backstage.image.registry | Registry to pull the RHDH image from. | string | `quay.io` |
| upstream.backstage.image.repository | Repository to pull the RHDH image from. | string | `rhdh/rhdh-hub-rhel9` |
| upstream.backstage.image.repository | RHDH image tag. | string | `1.5` |

## Contributing

For contributions to this chart, utilize the production or development environment as needed for testing.

### Pull Requests

If you want to submit code changes to this project, here are some guidelines:

1. **Create a branch - not from a fork.**

    Our PR test workflows utilize Github secrets, which are only accessible on branches of this repository, not from forks. If you receive an error during tests related to Quay authentication, verify that the PR was not opened from a fork.

2. **Implement your changes**

    If you make changes to required values that users must update before deployment, document this in the **"Values"** section above.

3. **Testing and Linting**

    You can use the `helm lint` command to test if your changes pass the linting check.

    For "local" testing, try deploying the helm chart with the development and production environments to your own OpenShift cluster.

4. **Open a pull request**

    Open a PR to automatically run our test workflows. Provide a clear description of the changes, including any Jira tickets or Github issues associated with the work. Provide an example of how to test your changes, if relevant.
