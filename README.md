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

NOTE: Currently this helm chart has no public releases. To use this chart, you must clone this repository and install the chart from source. 

```console
git clone https://github.com/ansible-automation-platform/ansible-portal-chart.git
cd ansible-portal-chart
helm dependency update
```

## Choose environment

Before installing the chart, determine which environment to use. There are two environments: **development** and **production**. 

If you are using this chart as part of an internal Red Hat team looking to test with the chart and ansible-backstage-plugins, you will likely want to use the development values. 

If you are using this chart in a production environment, you will need to use the production values. 

## Installing from chart source

The following command can be used to add the RHDH Backstage Chart repository:

```console
helm repo add redhat-developer-hub https://charts.openshift.io
```


### Update values.yaml

To make this chart work properly, update the placeholder values in values.yaml.

- To get proper connection between frontend and backend of Backstage please update the clusterRouteBase key with value `apps.example.com` to match your cluster host URL:
  
     ```yaml
     # values.yaml
     global:
       clusterRouterBase: apps.example.com
     ```

- Update the `appConfig.ansible.rhaap` `baseUrl` and `token` values from "changeme" to the ip or URL of your AAP instance and an authentication token from the AAP instance.

     ```yaml
     # values.yaml
       appConfig:
          enableExperimentalRedirectFlow: true
          ansible:
            rhaap:
              baseUrl: "changeme"  # in the form https://<ip-or-url-to-AAP-instance>
              token: "changeme"
     ```
- Update the `appConfig.auth.providers.rhaap.production` `host`, `clientId`, and `clientSecret` values from "changeme" to the ip or URL of your AAP instance, AAP OAuth application clientId, and AAP Oauth clientSecret respectively. 

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

- If using the development environment, you can either update the Quay image tag inside the values-dev.yaml file manually, or pass the value via the command line.
  
     ```yaml
     # values-dev.yaml
      global:
        imageTagInfo: # Required: Update here or pass using --set
     ```


### Installing with the correct environment setting

After determining which environment to use and updating the values.yaml file, the chart is ready to install. 

If using the production environment, the following command can be used to install the chart:

```console
helm install my-rhdh <path-to-chart> -f values-prod.yaml
```

If using the development environment, use the following command:

```console
helm install my-rhdh <path-to-chart> -f values-dev.yaml
```

## Additional Development Environment Configuration

If using the development environment, there are a few more settings to configure before installing the chart. 

Ensure your podman/docker credentials are stored in an auth.json file. Next, use the below command to add a secret to your Openshift environment using the auth file. 

```console
oc create secret generic <projectname>-dynamic-plugins-registry-auth --from-file=<path-to-auth.json>
```

Note: The secret must have this exact name pattern in order to work correctly. 
