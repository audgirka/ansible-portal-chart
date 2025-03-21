# ansible-portal-chart

TL;DR

Add helm reposiotry dependency
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add backstage https://backstage.github.io/charts
helm repo add openshift-helm-charts https://charts.openshift.io
```

Clone the repository and download the dependency
```
cd ansible-portal-chart
helm dependency update
cd ..
```

Install helm chart
```
helm install my-portal ansible-portal-chart
```
